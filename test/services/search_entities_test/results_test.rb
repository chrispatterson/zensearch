# frozen_string_literal: true

require 'test_helper'

module SearchEntitiesTest
  class ResultsTest < ActiveSupport::TestCase
    test 'finds_by_boolean' do
      org_search_params = { shared_tickets: true }
      shared_org = create_organization!(shared_tickets: true)
      search = SearchEntities.call(Organization, org_search_params)

      assert_includes search.results, shared_org, 'Should find organizations by boolean value'
      refute_includes search.results, default_organization, 'Should exclude organizations by boolean value'

      ticket_search_params = { has_incidents: true }
      incident_ticket = create_ticket!(has_incidents: true)
      search = SearchEntities.call(Ticket, ticket_search_params)

      assert_includes search.results, incident_ticket, 'Should find tickets by boolean value'
      refute_includes search.results, default_ticket, 'Should exclude tickets by boolean value'

      user_search_params = { active: false }
      inactive_user = create_user!(active: false)
      search = SearchEntities.call(User, user_search_params)

      assert_includes search.results, inactive_user, 'Should find users by boolean value'
      refute_includes search.results, default_user, 'Should exclude users by boolean value'
    end

    test 'finds_by_date' do
      yesterday = (DateTime.now + 1.day).utc.to_s
      org_search_params = { created_at: yesterday }
      shared_org = create_organization!(created_at: yesterday)
      search = SearchEntities.call(Organization, org_search_params)

      assert_includes search.results, shared_org, 'Should find organizations by date value'
      refute_includes search.results, default_organization, 'Should exclude organizations by date value'

      ticket_search_params = { due_at: yesterday }
      incident_ticket = create_ticket!(due_at: yesterday)
      search = SearchEntities.call(Ticket, ticket_search_params)

      assert_includes search.results, incident_ticket, 'Should find tickets by date value'
      refute_includes search.results, default_ticket, 'Should exclude tickets by date value'

      user_search_params = { last_login_at: yesterday }
      inactive_user = create_user!(last_login_at: yesterday)
      search = SearchEntities.call(User, user_search_params)

      assert_includes search.results, inactive_user, 'Should find users by date value'
      refute_includes search.results, default_user, 'Should exclude users by date value'
    end

    test 'finds_by_enum' do
      ticket_search_params = { priority: :urgent }
      urgent_ticket = create_ticket!(priority: :urgent)
      search = SearchEntities.call(Ticket, ticket_search_params)

      assert_includes search.results, urgent_ticket, 'Should find tickets by enum value'
      refute_includes search.results, default_ticket, 'Should exclude tickets by enum value'

      user_search_params = { role: :agent }
      agent_user = create_user!(role: :agent)
      search = SearchEntities.call(User, user_search_params)

      assert_includes search.results, agent_user, 'Should find users by enum value'
      refute_includes search.results, default_user, 'Should exclude users by enum value'
    end

    test 'finds_by_fulltext_when_blank' do
      search_params = { text: '' }
      blank_text_org = create_organization!(details: '')
      search = SearchEntities.call(Organization, search_params)

      assert_includes search.results, blank_text_org, 'Should find organizations by blank text value'
      refute_includes search.results, default_organization, 'Should exclude organizations by blank text value'

      blank_text_ticket = create_ticket!(description: '')
      search = SearchEntities.call(Ticket, search_params)

      assert_includes search.results, blank_text_ticket, 'Should find tickets by blank text value'
      refute_includes search.results, default_ticket, 'Should exclude tickets by blank text value'

      blank_text_user = create_user!(name: '')
      search = SearchEntities.call(User, search_params)

      assert_includes search.results, blank_text_user, 'Should find users by blank text value'
      refute_includes search.results, default_user, 'Should exclude users by blank text value'
    end

    test 'finds_by_fulltext_when_present' do
      org_search_params = { text: 'consume' }
      text_org = create_organization!(name: 'Omni Consumer Products')
      search = SearchEntities.call(Organization, org_search_params)

      assert_includes search.results, text_org, 'Should find organizations by present text value'
      refute_includes search.results, default_organization, 'Should exclude organizations by present text value'

      ticket_search_params = { text: 'volt' }
      text_ticket = create_ticket!(subject: 'The robots are revolting')
      search = SearchEntities.call(Ticket, ticket_search_params)

      assert_includes search.results, text_ticket, 'Should find tickets by present text value'
      refute_includes search.results, default_ticket, 'Should exclude tickets by present text value'

      user_search_params = { text: 'rip' }
      text_user = create_user!(user_alias: 'Ellen Ripley')
      search = SearchEntities.call(User, user_search_params)

      assert_includes search.results, text_user, 'Should find users by present text value'
      refute_includes search.results, default_user, 'Should exclude users by present text value'
    end

    test 'finds_by_join_domain_names' do
      domain_name = 'brawndo.com'
      domain_org = create_organization!
      domain_org.domain_names << DomainName.where(name: domain_name).first_or_create!
      org_search_params = { domain_names: domain_name }
      search = SearchEntities.call(Organization, org_search_params)

      assert_includes search.results, domain_org, 'Should find organizations by domain_name value'
      refute_includes search.results, default_organization, 'Should exclude organizations by domain_name value'
    end

    test 'finds_by_join_tags' do
      tag_name = 'nostromo'
      tag = Tag.where(name: tag_name).first_or_create!

      search_params = { tags: tag_name }

      tag_org = create_organization!
      tag_org.tags << tag
      search = SearchEntities.call(Organization, search_params)

      assert_includes search.results, tag_org, 'Should find organizations by tag value'
      refute_includes search.results, default_organization, 'Should exclude organizations by tag value'

      tag_ticket = create_ticket!
      tag_ticket.tags << tag
      search = SearchEntities.call(Ticket, search_params)

      assert_includes search.results, tag_ticket, 'Should find tickets by tag value'
      refute_includes search.results, default_ticket, 'Should exclude tickets by tag value'

      tag_user = create_user!
      tag_user.tags << tag
      search = SearchEntities.call(User, search_params)

      assert_includes search.results, tag_user, 'Should find users by tag value'
      refute_includes search.results, default_user, 'Should exclude users by tag value'
    end

    test 'finds_by_other' do
      ticket_search_params = { assignee_id: 555 }
      assignee_ticket = create_ticket!(assignee_id: 555)
      search = SearchEntities.call(Ticket, ticket_search_params)

      assert_includes search.results, assignee_ticket, 'Should find tickets by other value'
      refute_includes search.results, default_ticket, 'Should exclude tickets by other value'

      user_search_params = { locale: 'da-DK' }
      locale_user = create_user!(locale: 'da-DK')
      search = SearchEntities.call(User, user_search_params)

      assert_includes search.results, locale_user, 'Should find users by other value'
      refute_includes search.results, default_user, 'Should exclude users by other value'
    end
  end
end
