# Canvas JS for expense report charts
Rails.application.config.assets.precompile += %w(
  canvasjs.min.js expense_entries.js expense_reports.js
  users.js welcome.js
)