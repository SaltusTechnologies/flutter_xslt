#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_xslt.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_xslt'
  s.module_name = 'flutter_xslt'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin that transforms xml with xslt.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = [
    'Classes/**/*.{h,m,mm,swift}',
    'Headers/**/*.{h}'
  ]
  s.libraries = 'z', 'iconv'
  # XCFrameworks (device + simulator arm64 slices) instead of the original
  # device-only vendored_libraries — a flat .a can only target one SDK at a
  # time, which is why the upstream package couldn't run on the iOS
  # simulator. XCFrameworks let Xcode pick the right slice automatically.
  s.vendored_frameworks = [
    'Lib/XCFrameworks/libxml2.xcframework',
    'Lib/XCFrameworks/libxslt.xcframework',
    'Lib/XCFrameworks/libexslt.xcframework'
  ]
   s.header_dir = 'flutter_xslt'
   s.private_header_files = 'Lib/Headers/**/*.h'
   s.public_header_files = 'Headers/XsltTransformer.h'
  s.dependency 'Flutter'
  # Doit matcher (ou dépasser) IOS_MIN utilisé par scripts/xmlxslt/build.sh
  # pour compiler libxml2/libxslt — un mismatch produit des avertissements de
  # linker ("built for iOS X, which is newer than...").
  s.platform = :ios, '14.0'

  s.pod_target_xcconfig = {
  'DEFINES_MODULE' => 'YES',
  'CLANG_ENABLE_MODULES' => 'NO',
  'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
  'HEADER_SEARCH_PATHS'  => [
      '$(PODS_TARGET_SRCROOT)/Lib/Headers ',
      '$(PODS_TARGET_SRCROOT)/Lib/Headers/libexslt ',
      '$(PODS_TARGET_SRCROOT)/Lib/Headers/libxslt ',
      '$(PODS_TARGET_SRCROOT)/Lib/Headers/libxml2/libxml ',
      '$(PODS_TARGET_SRCROOT)/Lib/Headers/libxml2 '
    ].join(' ')

  }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'flutter_xslt_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
