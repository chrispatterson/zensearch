# frozen_string_literal: true

require 'test_helper'

class BuildSearchScopeTest < ActiveSupport::TestCase
  setup :do_setup

  def do_setup
    @search_params = {
      active: true,
      last_login_at: Time.now.utc,
      role: :admin,
      locale: 'da-DK',
      tags: ['it'],
      domain_names: ['blue-sun.org'],
      priority: :high,
      text: 'cool'
    }
  end

  test 'resolves_search_fields' do
    org_scope = BuildSearchScope.call(Organization, @search_params)
    expected_org_fields = {
      boolean: [], date: [], enum: [],
      join: %i[tags domain_names], other: [],
      text: %i[url external_id name details]
    }
    assert_equal expected_org_fields, org_scope.search_fields

    ticket_scope = BuildSearchScope.call(Ticket, @search_params)
    expected_ticket_fields = {
      boolean: [], date: [],
      enum: [:priority], join: [:tags],
      other: [],
      text: %i[id url external_id subject description]
    }
    assert_equal expected_ticket_fields, ticket_scope.search_fields

    user_scope = BuildSearchScope.call(User, @search_params)
    expected_user_fields = {
      boolean: [:active], date: [:last_login_at], enum: [:role],
      join: [:tags], other: [:locale],
      text: %i[url external_id name user_alias email phone signature]
    }
    assert_equal expected_user_fields, user_scope.search_fields
  end

  test 'builds_boolean_scope' do
    boolean_search_params = { active: true }
    boolean_scope = BuildSearchScope.call(User, boolean_search_params)

    expected_sql = 'SELECT "users".* FROM "users" WHERE "users"."active" = 1'

    assert_equal expected_sql, boolean_scope.scope.to_sql
  end

  test 'builds_date_scope' do
    date_search_params = { due_at: '2020-02-18 01:49:23 UTC'.to_datetime }
    date_scope = BuildSearchScope.call(Ticket, date_search_params)

    expected_sql = 'SELECT "tickets".* FROM "tickets" WHERE "tickets"."due_at" '\
                  'BETWEEN \'2020-02-18 00:00:00\' AND \'2020-02-18 23:59:59.999999\''

    assert_equal expected_sql, date_scope.scope.to_sql
  end

  test 'builds_enum_scope' do
    enum_search_params = { role: :admin }
    enum_scope = BuildSearchScope.call(User, enum_search_params)

    expected_sql = 'SELECT "users".* FROM "users" WHERE "users"."role" = ' + User.roles[:admin].to_s

    assert_equal expected_sql, enum_scope.scope.to_sql
  end

  test 'builds_join_scope_when_exists' do
    domain_name = 'brawndo.com'
    domain_org = create_organization!
    domain_org.domain_names << DomainName.where(name: domain_name).first_or_create!

    join_search_params = { domain_names: domain_name }
    join_scope = BuildSearchScope.call(Organization, join_search_params)

    expected_sql = 'SELECT "organizations".* FROM "organizations" WHERE "organizations"."id" = ' + domain_org.id.to_s

    assert_equal expected_sql, join_scope.scope.to_sql
  end

  test 'builds_join_scope_when_not_exists' do
    join_search_params = { domain_names: 'unlikely-to-exist.edu' }
    join_scope = BuildSearchScope.call(Organization, join_search_params)

    expected_sql = 'SELECT "organizations".* FROM "organizations" WHERE 1=0'

    assert_equal expected_sql,
                 join_scope.scope.to_sql,
                 'join scopes should return ActiveRecord::NullRelation when the association does not exist'
  end

  test 'builds_other_scope' do
    other_search_params = { assignee_id: 555 }
    other_scope = BuildSearchScope.call(Ticket, other_search_params)

    expected_sql = 'SELECT "tickets".* FROM "tickets" WHERE "tickets"."assignee_id" = 555'

    assert_equal expected_sql, other_scope.scope.to_sql
  end

  test 'builds_present_text_scope' do
    text_search_params = { text: 'Multi National United' }
    text_scope = BuildSearchScope.call(Organization, text_search_params)

    expected_sql =
      'SELECT "organizations".* FROM "organizations" WHERE ((("organizations"."url" '\
      'LIKE \'%Multi National United%\' OR "organizations"."external_id" LIKE \'%Multi National United%\') OR '\
      '"organizations"."name" LIKE \'%Multi National United%\') OR '\
      '"organizations"."details" LIKE \'%Multi National United%\')'

    assert_equal expected_sql, text_scope.scope.to_sql
  end

  test 'builds_absent_text_scope' do
    text_search_params = { text: '' }
    text_scope = BuildSearchScope.call(Organization, text_search_params)

    expected_sql =
      'SELECT "organizations".* FROM "organizations" WHERE (((("organizations"."url" IS NULL OR "organizations"."url" '\
      '= \'\') OR ("organizations"."external_id" IS NULL OR "organizations"."external_id" = \'\')) OR '\
      '("organizations"."name" IS NULL OR "organizations"."name" = \'\')) OR ("organizations"."details" IS NULL OR '\
      '"organizations"."details" = \'\'))'

    assert_equal expected_sql, text_scope.scope.to_sql
  end
end
