require_relative '../update_android_sdk'

class TestUpdateAndroidSDK < MiniTest::Unit::TestCase
  def test_should_NOT_return_unmatched_filters
    expects = []
    rejects = ["3- ARM EABI v7a System Image, Android API 17"]
    assert_filters expects, rejects, %w[android-8-17 google-api-10]
  end

  def test_should_include_androids
    expects = ["13- SDK Platform Android 2.2, API 8, revision 3", 
               "12- SDK Platform Android 2.3.1, API 9, revision 2",
               "11- SDK Platform Android 2.3.3, API 10, revision 2",
               "48- Google APIs, Android API 10, revision 2"]
    rejects = []
    assert_filters expects, rejects, %w[android-8-10 google-api-10]
  end

  def test_cmd_android_update_should_use_indices
    filters = filters_for(avail_sdk_lines, %w[android-8-10 google-api-10])
    cmd = cmd_android_update('home', filters)
    assert_equal 'home/tools/android update sdk --no-ui --filter 11,12,13,48', cmd
  end

  def test_cmd_android_update_should_use_indices_for_other_filter_strings
    filters = filters_for(avail_sdk_lines, "Google")
    cmd = cmd_android_update('home', filters)
    assert_equal 'home/tools/android update sdk --no-ui --filter 39,40,41,43,45,46,47,48,53,54,57,58,59,60,61,67,68,69,70,71,72,73,74', cmd
  end

  def test_cmd_android_update_should_use_built_in_filters
    filters = filters_for(avail_sdk_lines, %w[add-on doc extra platform-tool])
    cmd = cmd_android_update('home', filters)
    assert_equal 'home/tools/android update sdk --no-ui --filter add-on,doc,extra,platform-tool', cmd
  end

  def test_should_populate_filter_to_send
    filters = filters_for(avail_sdk_lines, 'android-8-10', 'google-api-10')
    filters.each do |filter|
      expected = filter.description[/^\s*(\d+)-.+/, 1]
      assert_equal expected, filter.filter_to_send
    end
  end

  def test_should_support_built_in_filter_strings
    filters = filters_for(avail_sdk_lines, 'doc')
    assert_equal 'doc', filters[0].filter_to_send
  end

  def test_should_match_any_other_strings
    expects = [
      "67- Google AdMob Ads SDK, revision 8",
      "68- Google Analytics SDK, revision 2",
      "69- Google Cloud Messaging for Android Library, revision 3",
      "70- Google Play services, revision 1",
      "71- Google Play APK Expansion Library, revision 2",
      "72- Google Play Billing Library, revision 2",
      "73- Google Play Licensing Library, revision 2",
      "74- Google Web Driver, revision 2",
      "48- Google APIs, Android API 10, revision 2"]
    rejects = ['Intel x86 Emulator Accelerator']
    assert_filters expects, rejects, 'Google'
  end

  def assert_filters(expects, rejects, *filter_strings)
    filters = filters_for(avail_sdk_lines, filter_strings.flatten)

    missings = expects.clone
    hates = []
    filters.each do |filter|
      missings.delete_if {|e| filter.description.include?(e)}
      hates << filter.description if rejects.any?{|r| filter.description.include?(r)}
    end
    assert missings.empty?, "missings=#{missings}"
    assert hates.empty?, "hates=#{hates}"
  end

  def avail_sdk_lines
%q{
Refresh Sources:
  Fetching https://dl-ssl.google.com/android/repository/addons_list-2.xml
  Validate XML
  Parse XML
  Fetched Add-ons List successfully
  Refresh Sources
  Fetching URL: https://dl-ssl.google.com/android/repository/repository-7.xml
  Validate XML: https://dl-ssl.google.com/android/repository/repository-7.xml
  Parse XML:    https://dl-ssl.google.com/android/repository/repository-7.xml
  Fetching URL: https://dl-ssl.google.com/android/repository/addon.xml
  Validate XML: https://dl-ssl.google.com/android/repository/addon.xml
  Parse XML:    https://dl-ssl.google.com/android/repository/addon.xml
  Fetching URL: http://dl.htcdev.com/sdk/addon.xml
  Validate XML: http://dl.htcdev.com/sdk/addon.xml
  Parse XML:    http://dl.htcdev.com/sdk/addon.xml
  Fetching URL: http://software.intel.com/sites/landingpage/android/addon.xml
  Validate XML: http://software.intel.com/sites/landingpage/android/addon.xml
  Parse XML:    http://software.intel.com/sites/landingpage/android/addon.xml
  Fetching URL: http://www.echobykyocera.com/download/echo_repository.xml
  Validate XML: http://www.echobykyocera.com/download/echo_repository.xml
  Parse XML:    http://www.echobykyocera.com/download/echo_repository.xml
  Fetching URL: http://developer.lgmobile.com/sdk/android/repository.xml
  Validate XML: http://developer.lgmobile.com/sdk/android/repository.xml
  Parse XML:    http://developer.lgmobile.com/sdk/android/repository.xml
  Fetching URL: http://developer.sonymobile.com/edk/android/repository.xml
  Validate XML: http://developer.sonymobile.com/edk/android/repository.xml
  Parse XML:    http://developer.sonymobile.com/edk/android/repository.xml
  Fetching URL: https://dl-ssl.google.com/android/repository/sys-img.xml
  Validate XML: https://dl-ssl.google.com/android/repository/sys-img.xml
  Parse XML:    https://dl-ssl.google.com/android/repository/sys-img.xml
  Fetching URL: http://www.mips.com/global/sdk-sys-img.xml
  Validate XML: http://www.mips.com/global/sdk-sys-img.xml
  Parse XML:    http://www.mips.com/global/sdk-sys-img.xml
  Fetching URL: http://download-software.intel.com/sites/landingpage/android/sys-img.xml
  Validate XML: http://download-software.intel.com/sites/landingpage/android/sys-img.xml
  Parse XML:    http://download-software.intel.com/sites/landingpage/android/sys-img.xml
Packages available for installation or update: 75
   1- Android SDK Tools, revision 21
   2- Android SDK Platform-tools, revision 16
   3- Documentation for Android SDK, API 17, revision 1
   4- SDK Platform Android 4.2, API 17, revision 1
   5- SDK Platform Android 4.1.2, API 16, revision 3
   6- SDK Platform Android 4.0.3, API 15, revision 3
   7- SDK Platform Android 4.0, API 14, revision 3
   8- SDK Platform Android 3.2, API 13, revision 1
   9- SDK Platform Android 3.1, API 12, revision 3
  10- SDK Platform Android 3.0, API 11, revision 2
  11- SDK Platform Android 2.3.3, API 10, revision 2
  12- SDK Platform Android 2.3.1, API 9, revision 2 (Obsolete)
  13- SDK Platform Android 2.2, API 8, revision 3
  14- SDK Platform Android 2.1, API 7, revision 3
  15- SDK Platform Android 2.0.1, API 6, revision 1 (Obsolete)
  16- SDK Platform Android 2.0, API 5, revision 1 (Obsolete)
  17- SDK Platform Android 1.6, API 4, revision 3
  18- SDK Platform Android 1.5, API 3, revision 4
  19- SDK Platform Android 1.1, API 2, revision 1 (Obsolete)
  20- Samples for SDK API 17, revision 1
  21- Samples for SDK API 16, revision 1
  22- Samples for SDK API 15, revision 2
  23- Samples for SDK API 14, revision 2
  24- Samples for SDK API 13, revision 1
  25- Samples for SDK API 12, revision 1
  26- Samples for SDK API 11, revision 1
  27- Samples for SDK API 10, revision 1
  28- Samples for SDK API 9, revision 1 (Obsolete)
  29- Samples for SDK API 8, revision 1
  30- Samples for SDK API 7, revision 1
  31- ARM EABI v7a System Image, Android API 17, revision 1
  32- ARM EABI v7a System Image, Android API 16, revision 3
  33- Intel x86 Atom System Image, Android API 16, revision 1
  34- MIPS System Image, Android API 16, revision 2
  35- ARM EABI v7a System Image, Android API 15, revision 2
  36- Intel x86 Atom System Image, Android API 15, revision 1
  37- MIPS System Image, Android API 15, revision 1
  38- ARM EABI v7a System Image, Android API 14, revision 2
  39- Google APIs, Android API 17, revision 1
  40- Google APIs, Android API 16, revision 3
  41- Google APIs, Android API 15, revision 2
  42- HTC OpenSense SDK, Android API 15, revision 2
  43- Google APIs, Android API 14, revision 2
  44- Real3D, Android API 14, revision 1
  45- Google APIs, Android API 13, revision 1
  46- Google APIs, Android API 12, revision 1
  47- Google APIs, Android API 11, revision 1
  48- Google APIs, Android API 10, revision 2
  49- Intel Atom x86 System Image, Android API 10, revision 1
  50- Dual Screen APIs, Android API 10, revision 1
  51- Real3D, Android API 10, revision 2
  52- Sony Xperia Extensions EDK 2.0, Android API 10, revision 2
  53- Google APIs, Android API 9, revision 2 (Obsolete)
  54- Google APIs, Android API 8, revision 2
  55- Dual Screen APIs, Android API 8, revision 1
  56- Real3D, Android API 8, revision 1
  57- Google APIs, Android API 7, revision 1
  58- Google APIs, Android API 6, revision 1 (Obsolete)
  59- Google APIs, Android API 5, revision 1 (Obsolete)
  60- Google APIs, Android API 4, revision 2
  61- Google APIs, Android API 3, revision 3
  62- Sources for Android SDK, API 17, revision 1
  63- Sources for Android SDK, API 16, revision 2
  64- Sources for Android SDK, API 15, revision 2
  65- Sources for Android SDK, API 14, revision 1
  66- Android Support Library, revision 11
  67- Google AdMob Ads SDK, revision 8
  68- Google Analytics SDK, revision 2
  69- Google Cloud Messaging for Android Library, revision 3
  70- Google Play services, revision 1
  71- Google Play APK Expansion Library, revision 2
  72- Google Play Billing Library, revision 2
  73- Google Play Licensing Library, revision 2
  74- Google Web Driver, revision 2
  75- Intel x86 Emulator Accelerator (HAXM), revision 2
}
  end
end
