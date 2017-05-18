WickedPdf.config = {
  :wkhtmltopdf => Rails.env.development? ? Rails.root.join('bin', 'wkhtmltopdf-osx').to_s : Rails.root.join('bin', 'wkhtmltopdf-amd64').to_s,
  :exe_path => Rails.env.development? ? Rails.root.join('bin', 'wkhtmltopdf-osx').to_s : Rails.root.join('bin', 'wkhtmltopdf-amd64').to_s
}
