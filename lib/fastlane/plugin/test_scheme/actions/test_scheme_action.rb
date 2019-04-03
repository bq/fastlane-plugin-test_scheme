require 'fastlane/action'
require_relative '../helper/test_scheme_helper'

module Fastlane
  module Actions
    class TestSchemeAction < Action
      def self.run(params)
        ENV['XCPRETTY_JSON_FILE_OUTPUT'] = "./output/#{params[:name]}.build-report.json"
        Actions::ScanAction.run(
          scheme: params[:scheme],
          configuration: params[:configuration],
          disable_concurrent_testing: true,
          max_concurrent_simulators: 1,
          buildlog_path: "./output",
          output_directory: "./output",
          formatter: 'xcpretty-json-formatter',
          skip_slack: true
        )
        report = Actions::TrainerAction.run(output_directory: "./output")
        report_path, report_finished = report.first
        File.rename(".#{report_path}", "../output/#{params[:name]}.test-report.xml") if report_finished
      end

      def self.description
        "Launch scan to generate JSON report from xcpretty and XML report with trainer in the specific folder"
      end

      def self.authors
        ["sebastianvarela"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Fastlane plugin in charge of launching scan to generate JSON report from xcpretty and XML report with trainer in the specific folder"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :output_directory,
                                       env_name: "TEST_SCHEME_OUTPUT_DIRECTORY",
                                       description: "Path to the directory that should be converted",
                                       default_value: "./ouput",
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :scheme,
                                       env_name: "TEST_SCHEME_SCHEME",
                                       description: "Path to the directory that should be converted",
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :configuration,
                                       env_name: "TEST_SCHEME_CONFIGURATION",
                                       description: "Path to the directory that should be converted",
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: "TEST_SCHEME_NAME",
                                       description: "Path to the directory that should be converted",
                                       type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
