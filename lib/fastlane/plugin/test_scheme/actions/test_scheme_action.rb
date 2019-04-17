require 'fastlane/action'
require_relative '../helper/test_scheme_helper'

module Fastlane
  module Actions
    class TestSchemeAction < Action
      def self.run(params)
        output_directory = File.expand_path(params[:output_directory])

        ENV['XCPRETTY_JSON_FILE_OUTPUT'] = "#{params[:output_directory]}/#{params[:name]}.build-report.json"

        config = FastlaneCore::Configuration.create(Fastlane::Actions::ClearDerivedDataAction.available_options, {})
        Fastlane::Actions::ClearDerivedDataAction.run(config) if params[:clear_derived_data]

        scan_options = {}
        scan_options[:scheme] = params[:scheme]
        scan_options[:configuration] = params[:configuration]
        scan_options[:disable_concurrent_testing] = true
        scan_options[:max_concurrent_simulators] = 1
        scan_options[:buildlog_path] = output_directory
        scan_options[:output_directory] = output_directory
        scan_options[:formatter] = "xcpretty-json-formatter"
        scan_options[:skip_slack] = true
        config = FastlaneCore::Configuration.create(Fastlane::Actions::ScanAction.available_options, scan_options)
        Fastlane::Actions::ScanAction.run(config)

        trainer_options = {}
        trainer_options[:output_directory] = output_directory
        config = FastlaneCore::Configuration.create(Fastlane::Actions::TrainerAction.available_options, trainer_options)
        report = Actions::TrainerAction.run(config)
        report_path, report_finished = report.first
        report_desired_path = "#{output_directory}/#{params[:name]}.test-report.xml"

        if report_finished 
          File.rename(report_path, report_desired_path) 
          UI.message "Reporte renamed to: #{report_desired_path}"
        end
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
          FastlaneCore::ConfigItem.new(key: :clear_derived_data,
                                       env_name: "TEST_SCHEME_CLEAR_DERIVED_DATA",
                                       description: "Clear derived data before start testing",
                                       default_value: true,
                                       is_string: false),          
          FastlaneCore::ConfigItem.new(key: :output_directory,
                                       env_name: "TEST_SCHEME_OUTPUT_DIRECTORY",
                                       description: "Path to the directory that should be converted",
                                       default_value: "./output",
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
