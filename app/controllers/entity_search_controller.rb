# frozen_string_literal: true

class EntitySearchController < ApplicationController
  # GET /
  def index
  end

  # GET /search
  def results
    @organizations = find_organizations
    @tickets = find_tickets
    @users = find_users
  end

  private

    def find_organizations
      org_search_params = permitted_search_params.to_h.merge(permitted_org_params.to_h)

      SearchEntities.call(Organization, org_search_params).results
        .includes(:domain_names, :tags)
    end

    def find_tickets
      ticket_search_params = permitted_search_params.to_h.merge(permitted_ticket_params.to_h)

      SearchEntities.call(Ticket, ticket_search_params).results
        .includes(:tags)
    end

    def find_users
      user_search_params = permitted_search_params.to_h.merge(permitted_user_params.to_h)

      SearchEntities.call(User, user_search_params).results
        .includes(:tags)
    end

    def permitted_org_params
      params.fetch(:org, {}).permit(
        %i[shared_tickets created_at details external_id name url domain_names id tags]
      )
    end

    def permitted_search_params
      params.permit(:text)
    end

    def permitted_ticket_params
      params.fetch(:ticket, {}).permit(
        %i[
          has_incidents created_at due_at priority status type via description external_id
          id subject url tags assignee_id id organization_id submitter_id
        ]
      )
    end

    def permitted_user_params
      params.fetch(:user, {}).permit(
        %i[
          active verified shared suspended created_at last_login_at role url external_id
          name user_alias email phone signature tags locale timezone organization_id
        ]
      )
    end
end
