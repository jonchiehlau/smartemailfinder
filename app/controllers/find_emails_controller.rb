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
              .concat(params[:persons].map{|person| person.values.to_csv}).join, :filename => 'emails.csv'
  end
end
