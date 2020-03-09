# frozen_string_literal: true

require 'test_helper'

module SearchEntitiesTest
  class SearchDataTest < ActiveSupport::TestCase
    test 'expands_text_parameter' do
      search_params = { text: 'shazbot' }

      org_search = SearchEntities.call(Organization, search_params)
      expected_org_fields = {
        details: 'shazbot', external_id: 'shazbot', name: 'shazbot', url: 'shazbot'
      }.with_indifferent_access
      assert_equal expected_org_fields, org_search.search_data, 'Organization search failed to expand text parameter'

      ticket_search = SearchEntities.call(Ticket, search_params)
      expected_ticket_data = {
        id: 'shazbot', url: 'shazbot', external_id: 'shazbot', subject: 'shazbot', description: 'shazbot'
      }.with_indifferent_access
      assert_equal expected_ticket_data, ticket_search.search_data, 'Ticket search failed to expand text parameter'

      user_search = SearchEntities.call(User, search_params)
      expected_user_data = {
        url: 'shazbot', external_id: 'shazbot', name: 'shazbot', user_alias: 'shazbot',
        email: 'shazbot', phone: 'shazbot', signature: 'shazbot'
      }.with_indifferent_access
      assert_equal expected_user_data, user_search.search_data, 'User search failed to expand text parameter'
    end

    test 'transforms_booleans_correctly' do
      search_params = { active: 'false', verified: '0',  shared: 0,  suspended: 'nanoo nanoo' }

      search = SearchEntities.call(User, search_params)
      expected_data = { active: false, verified: false,  shared: false,  suspended: true }.with_indifferent_access
      assert_equal expected_data, search.search_data
    end

    test 'transforms_dates_correctly' do
      search_params = { created_at: 'Thursday, September 3rd, 1981', due_at: '12/01/1992' }

      search = SearchEntities.call(Ticket, search_params)
      expected_data = { created_at: Date.new(1981, 9, 3), due_at: Date.new(1992, 1, 12) }.with_indifferent_access
      assert_equal expected_data, search.search_data
    end

    test 'transforms_underscore_prefixed_id_correctly' do
      search_params = { _id: 'meat popsicle' }

      search = SearchEntities.call(Ticket, search_params)
      expected_data = { id: 'meat popsicle' }.with_indifferent_access
      assert_equal expected_data, search.search_data, '_id searches should be transformed into id searches'
    end
  end
end
