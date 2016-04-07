# Canvas JS for expense report charts
Rails.application.config.assets.precompile += %w(
  expense_entries.js expense_reports.js item_types.js
)