#
# Be sure to run `pod lib lint AGT.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AGT'
  s.version          = '1.0.0'
  s.summary          = 'AGT - Automation Generating Tests.'
  s.homepage         = 'https://github.com/rishatl/AGT'
  s.license          = { type: 'CUSTOM', text: "Copyright (c) #{Date.today.year} r.latypov" }
  s.author           = { 'Latypov Rishat Ildarovich' => 'rishatl@inbox.ru' }
  s.source           = { git: "https://github.com/rishatl/AGT.git", tag: "AGT/#{s.version}" }

  s.ios.deployment_target = '13.0'
  s.static_framework = true
  s.swift_version = '5.0'
  s.frameworks = 'XCTest', 'Foundation', 'UIKit', 'CoreGraphics'
  s.source_files = 'AGT/Sources/**/*.{h,m,swift}'
  s.prefix_header_file = false
  s.module_map = false

  s.pod_target_xcconfig = {
    'SWIFT_INSTALL_OBJC_HEADER' => 'NO',
    'SWIFT_OBJC_INTERFACE_HEADER_NAME' => '',
    'ENABLE_TESTING_SEARCH_PATHS' => 'YES',
    'EXCLUDED_SOURCE_FILE_NAMES' => '*-dummy.m'
  }

  # Resources
  r_swift_resources = [
    "#{s.name}/Resources/**/*.{xcassets,strings,stringsdict,xcdatamodeld,json}"
  ]
  r_swift_input_file_list = "#{s.name}/#{s.name}-Rswift-InputFiles.xcfilelist"
  s.preserve_path = r_swift_input_file_list

  r_swift_prepare_script = <<-SCRIPT
    require "fileutils"
    FileUtils.touch "#{s.name}/Sources/R.generated.swift"
    r_swift_input_files = #{r_swift_resources}.map { |p| Dir.glob(p) }.flatten.map { |p| "${PODS_TARGET_SRCROOT}/\#{p}" }
    File.open("#{r_swift_input_file_list}", "w") { |file| file.write(r_swift_input_files.join("\n")) }
  SCRIPT

  s.prepare_command = <<-SCRIPT
    ruby -e '#{r_swift_prepare_script}'
  SCRIPT

  resources_bundle_name = "#{s.name}Resources"
  s.resource_bundles = {
    resources_bundle_name => r_swift_resources
  }

  r_swift_output = "${PODS_TARGET_SRCROOT}/#{s.name}/Sources/R.generated.swift"
  r_swift_script = <<~SCRIPT
      [[ $ACTION == "indexbuild" ]] && exit
      "$PODS_ROOT/R.swift/rswift" generate "#{r_swift_output}" --hostingBundle '#{resources_bundle_name}' --target '#{s.name}-#{s.name}Resources'
      chmod 0666 "#{r_swift_output}"
      sed -i '' -e 's/fileprivate static let hostingBundle /static let hostingBundle /g' "#{r_swift_output}"
      chmod 0444 "#{r_swift_output}"
  SCRIPT

  s.script_phases = [
    {
      name: 'R.swift',
      input_files: ["${PODS_TARGET_SRCROOT}/#{r_swift_input_file_list}"],
      output_files: [r_swift_output],
      script: r_swift_script,
      execution_position: :before_compile,
      show_env_vars_in_log: '0'
    }
  ]

  s.dependency 'R.swift', '~> 6.1.0'
  s.dependency 'Swifter'
  s.dependency 'SwiftyJSON'
  s.dependency 'SSZipArchive'
  s.dependency 'iOSSnapshotTestCase', '~> 6.2.0'
  s.dependency 'SimulatorStatusMagic', '~> 2.7'

end
