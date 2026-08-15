#!/usr/bin/env ruby
# Adds MeBeWidget (Home Screen Widget) and MeBeActivityWidget (Live Activity / Dynamic Island)
# extension targets to the Xcode project programmatically.

require 'xcodeproj'
require 'fileutils'

PROJECT_PATH      = File.expand_path('../Runner.xcodeproj', __FILE__)
IOS_DIR           = File.expand_path('..', __FILE__)
MAIN_BUNDLE_ID    = 'com.mebe.mebeTracker'
APP_GROUP_ID      = 'group.com.mebe.mebetracker'
DEPLOYMENT_TARGET = '16.0'

puts "Opening #{PROJECT_PATH} ..."
project = Xcodeproj::Project.open(PROJECT_PATH)

runner_target = project.targets.find { |t| t.name == 'Runner' }
abort('Runner target not found') unless runner_target

# ── Helpers ────────────────────────────────────────────────────────────────────

def find_or_create_group(project, name, path)
  project.main_group.find_subpath(name) ||
    project.main_group.new_group(name, path)
end

def add_file_to_target(project, group, file_path, target)
  basename = File.basename(file_path)
  ref = group.files.find { |f| f.path == basename }
  unless ref
    ref = group.new_file(file_path)
  end
  target.source_build_phase.add_file_reference(ref) unless
    target.source_build_phase.files_references.include?(ref)
  ref
end

def write_entitlements(path, app_group_id)
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, <<~XML)
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>com.apple.security.application-groups</key>
      <array>
        <string>#{app_group_id}</string>
      </array>
    </dict>
    </plist>
  XML
  puts "  Wrote entitlements: #{path}"
end

def base_build_settings(bundle_id, deployment_target, entitlements_path)
  {
    'ALWAYS_SEARCH_USER_PATHS'           => 'NO',
    'CLANG_ANALYZER_NONNULL'             => 'YES',
    'CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION' => 'YES_AGGRESSIVE',
    'CODE_SIGN_ENTITLEMENTS'             => entitlements_path,
    'CODE_SIGN_STYLE'                    => 'Automatic',
    'DEBUG_INFORMATION_FORMAT'           => 'dwarf-with-dsym',
    'IPHONEOS_DEPLOYMENT_TARGET'         => deployment_target,
    'LD_RUNPATH_SEARCH_PATHS'            => '$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks',
    'MTL_ENABLE_DEBUG_INFO'              => 'INCLUDE_SOURCE',
    'PRODUCT_BUNDLE_IDENTIFIER'          => bundle_id,
    'PRODUCT_NAME'                       => '$(TARGET_NAME)',
    'SKIP_INSTALL'                       => 'YES',
    'SWIFT_ACTIVE_COMPILATION_CONDITIONS'=> 'DEBUG',
    'SWIFT_OPTIMIZATION_LEVEL'           => '-Onone',
    'SWIFT_VERSION'                      => '5.0',
    'TARGETED_DEVICE_FAMILY'             => '1,2',
  }
end

def ensure_app_group_capability(target, app_group_id)
  # xcodeproj doesn't write entitlement keys via API — we handle it via
  # the entitlements plist written separately and CODE_SIGN_ENTITLEMENTS.
  # App Groups also need to appear in the main app's entitlements.
  puts "  App Group '#{app_group_id}' will be applied via entitlements file."
end

def add_copy_files_phase(runner_target, extension_target, product_ref)
  phase = runner_target.copy_files_build_phases.find { |p| p.name == "Embed App Extensions" } ||
          runner_target.new_copy_files_build_phase("Embed App Extensions")
  phase.dst_subfolder_spec = '13' # PlugIns
  phase.dst_path = ''
  already = phase.files_references.any? { |r| r.path == product_ref.path }
  unless already
    build_file = phase.add_file_reference(product_ref)
    build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
    puts "  Added #{product_ref.path} to Embed App Extensions"
  end
end

# ── Write entitlements for Runner (main app) ──────────────────────────────────

runner_entitlements_path = "Runner/Runner.entitlements"
runner_entitlements_full = File.join(IOS_DIR, runner_entitlements_path)
unless File.exist?(runner_entitlements_full)
  write_entitlements(runner_entitlements_full, APP_GROUP_ID)
end
runner_target.build_configurations.each do |cfg|
  cfg.build_settings['CODE_SIGN_ENTITLEMENTS'] = runner_entitlements_path
end

# ── MeBeWidget (Home Screen Widget) ───────────────────────────────────────────

puts "\n── Adding MeBeWidget target ──────────────────────────────────────────────"

widget_name    = 'MeBeWidget'
widget_bundle  = "#{MAIN_BUNDLE_ID}.#{widget_name}"
widget_dir     = File.join(IOS_DIR, widget_name)
widget_ent_rel = "#{widget_name}/#{widget_name}.entitlements"
widget_ent_abs = File.join(IOS_DIR, widget_ent_rel)

write_entitlements(widget_ent_abs, APP_GROUP_ID)

existing_widget = project.targets.find { |t| t.name == widget_name }
if existing_widget
  puts "  Target '#{widget_name}' already exists — skipping creation."
  widget_target = existing_widget
else
  widget_target = project.new_target(
    :app_extension,
    widget_name,
    :ios,
    DEPLOYMENT_TARGET,
    project.products_group,
    :swift
  )
  puts "  Created target '#{widget_name}'"
end

widget_target.build_configurations.each do |cfg|
  settings = base_build_settings(widget_bundle, DEPLOYMENT_TARGET, widget_ent_rel)
  settings['INFOPLIST_FILE'] = "#{widget_name}/Info.plist"
  settings.each { |k, v| cfg.build_settings[k] = v }
end

# Add source group + file
widget_group = find_or_create_group(project, widget_name, widget_name)
swift_file    = File.join(widget_dir, "#{widget_name}.swift")
if File.exist?(swift_file)
  add_file_to_target(project, widget_group, swift_file, widget_target)
  puts "  Linked #{widget_name}.swift"
else
  puts "  WARNING: #{swift_file} not found — add it manually"
end

# Link Info.plist
info_plist = File.join(widget_dir, 'Info.plist')
if File.exist?(info_plist)
  ref = widget_group.files.find { |f| f.path == 'Info.plist' } ||
        widget_group.new_file(info_plist)
  puts "  Linked Info.plist"
end

# Embed into Runner
widget_product = widget_target.product_reference
add_copy_files_phase(runner_target, widget_target, widget_product)

# ── MeBeActivityWidget (Live Activity / Dynamic Island) ───────────────────────

puts "\n── Adding MeBeActivityWidget target ──────────────────────────────────────"

activity_name    = 'MeBeActivityWidget'
activity_bundle  = "#{MAIN_BUNDLE_ID}.#{activity_name}"
activity_dir     = File.join(IOS_DIR, activity_name)
activity_ent_rel = "#{activity_name}/#{activity_name}.entitlements"
activity_ent_abs = File.join(IOS_DIR, activity_ent_rel)

write_entitlements(activity_ent_abs, APP_GROUP_ID)

existing_activity = project.targets.find { |t| t.name == activity_name }
if existing_activity
  puts "  Target '#{activity_name}' already exists — skipping creation."
  activity_target = existing_activity
else
  activity_target = project.new_target(
    :app_extension,
    activity_name,
    :ios,
    DEPLOYMENT_TARGET,
    project.products_group,
    :swift
  )
  puts "  Created target '#{activity_name}'"
end

activity_target.build_configurations.each do |cfg|
  settings = base_build_settings(activity_bundle, DEPLOYMENT_TARGET, activity_ent_rel)
  settings['INFOPLIST_FILE'] = "#{activity_name}/Info.plist"
  settings.each { |k, v| cfg.build_settings[k] = v }
end

# Add source group + file
activity_group = find_or_create_group(project, activity_name, activity_name)
activity_swift  = File.join(activity_dir, "#{activity_name}.swift")
if File.exist?(activity_swift)
  add_file_to_target(project, activity_group, activity_swift, activity_target)
  puts "  Linked #{activity_name}.swift"
else
  puts "  WARNING: #{activity_swift} not found — add it manually"
end

info_plist2 = File.join(activity_dir, 'Info.plist')
if File.exist?(info_plist2)
  ref2 = activity_group.files.find { |f| f.path == 'Info.plist' } ||
         activity_group.new_file(info_plist2)
  puts "  Linked Info.plist"
end

# Embed into Runner
activity_product = activity_target.product_reference
add_copy_files_phase(runner_target, activity_target, activity_product)

# ── Save project ───────────────────────────────────────────────────────────────

project.save
puts "\n✅ project.pbxproj saved."
puts "\nNext steps:"
puts "  1. cd ios && pod install"
puts "  2. Open Runner.xcworkspace in Xcode → check Signing for each target"
puts "  3. Build and run on a real device"
