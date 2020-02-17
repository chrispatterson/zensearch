# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    def create_organization!(options = {})
      Organization.create!(
        {
          url: "https://#{SecureRandom.uuid}-tyrell.com",
          external_id: SecureRandom.uuid,
          name: 'Test Organization',
          details: 'Some details',
          shared_tickets: false
        }.merge(options)
      )
    end

    def create_ticket!(options = {})
      Ticket.create!(
        {
          url: "https://#{SecureRandom.uuid}-weyland.com",
          type: Ticket.types[:incident],
          subject: 'Test Ticket',
          description: 'Some cool description',
          priority: Ticket.priorities[:normal],
          status: Ticket.statuses[:open],
          submitter: default_user,
          assignee: nil,
          organization: default_organization,
          has_incidents: false,
          due_at: nil,
          via: Ticket.via[:web]
        }.merge(options)
      )
    end

    def create_user!(options = {})
      User.create!(
        {
          url: "https://#{SecureRandom.uuid}-primatech.com",
          name: 'Test User',
          user_alias: 'Spartacus',
          active: true,
          verified: false,
          shared: true,
          locale: 'en-US',
          timezone: 'Denmark',
          last_login_at: DateTime.now.utc - 7.days,
          email: "#{SecureRandom.uuid}@yoyodyne.com",
          phone: '273-8255',
          signature: "The ships hung in the sky, much the way that bricks don't.",
          organization: default_organization,
          suspended: false,
          role: User.roles['end-user']
        }.merge(options)
      )
    end

    def default_organization
      @default_organization || Organization.first
    end

    def default_user
      @default_user || User.first
    end
  end
end
