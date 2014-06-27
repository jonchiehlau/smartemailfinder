require 'csv'

class FindEmailsController < ApplicationController
  def add_names
  end

  def do_find
    logger.info params[:names]

    persons = params[:persons].map { |h| Person.new(h[:first_name], h[:last_name], h[:domain]) }

    begin
      @matched_persons = EmailFinder.new(persons).find_emails
    rescue FullContactException => e
      @error = e.message
    end
  end

  def export
    send_data [["First Name", "Last Name", "Email", "LinkedIn Profile", "Facebook Profile", "Twitter Profile"].to_csv]
              .concat(params[:persons].map { |person| person.values.to_csv }).join, :filename => 'emails.csv'
  end

  def bulk_upload

  end

  def do_find_bulk
    @matched_persons = []
    csv_file = params[:csv]

    begin
      spreadsheet = CSV.read(csv_file.path)
      spreadsheet.shift if spreadsheet[0][0] == 'First Name'

      persons = spreadsheet.map { |row| Person.new(row[0], row[1], row[2]) }
    rescue => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
      @error = 'Failed to parse the file.'
    end

    begin
      @matched_persons = EmailFinder.new(persons).find_emails
    rescue FullContactException => e
      @error = e.message
    end
    render 'do_find'
  end
end
