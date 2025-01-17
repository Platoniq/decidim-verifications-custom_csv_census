# frozen_string_literal: true

namespace :custom_csv_census do
  task init: %w(generate:custom_migration decidim_custom_csv_census:install:migrations db:migrate)

  desc "Rename all db entries with the new gem name"
  task rename_db_gem_name: :environment do
    # rubocop:disable Layout/LineLength
    # rubocop:disable Rails/SkipsModelValidations
    Decidim::ActionLog.where(resource_type: "Decidim::Verifications::CustomCsvCensus::CensusDataReport").update_all(resource_type: "Decidim::CustomCsvCensus::CensusDataReport")
    Decidim::ActionLog.where(resource_type: "Decidim::Verifications::CustomCsvCensus::CensusData").update_all(resource_type: "Decidim::CustomCsvCensus::CensusData")
    ActiveRecord::Base.connection.execute("UPDATE versions SET item_type = 'Decidim::CustomCsvCensus::CensusDataReport' WHERE item_type = 'Decidim::Verifications::CustomCsvCensus::CensusDataReport'")
    ActiveRecord::Base.connection.execute("UPDATE versions SET item_type = 'Decidim::CustomCsvCensus::CensusData' WHERE item_type = 'Decidim::Verifications::CustomCsvCensus::CensusData'")
    # rubocop:enable Layout/LineLength
    # rubocop:enable Rails/SkipsModelValidations
  end

  namespace :generate do
    desc "Generates a customized migration"
    task custom_migration: :environment do
      gem_root = Gem::Specification.find_by_name("decidim-custom_csv_census").gem_dir
      default_migration_name = "create_decidim_verifications_custom_csv_census_census_data.decidim_verifications_custom_csv_census.rb"
      default_migration_path = File.join(gem_root, "db", default_migration_name)
      text = File.read(default_migration_path)

      indexes = custom_fields.select { |_k, v| v[:search] }.keys.push(:decidim_organization_id)
      columns = custom_fields.map { |name, options| "t.#{options[:type].to_s.downcase} :#{name}" }
      replacement = columns.push("t.index #{indexes}, unique: true, name: 'index'").join("\n      ")

      timestamp = Dir[Rails.root.join("db/migrate/*")].max.split("/").last[0..13].to_i + 1
      puts "timestamp: #{timestamp}"
      new_migration_name = "#{timestamp}_#{default_migration_name}"
      file_name = Rails.root.join("db/migrate", new_migration_name)
      File.write(file_name.to_s, text.gsub("# replace me", replacement)) unless File.exist?(file_name)
      puts "Created migration #{file_name.basename}"
    end

    def custom_fields
      Decidim::CustomCsvCensus.configuration.fields
    end
  end
end
