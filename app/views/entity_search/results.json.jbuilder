# frozen_string_literal: true

[
  if @organizations.present?
    json.organizations do
      json.array!(@organizations) do |organization|
        json._id organization.id
        json.url organization.url
        json.external_id organization.external_id
        json.name organization.name
        json.domain_names organization.domain_names.map(&:name)
        json.created_at organization.created_at
        json.details organization.details
        json.shared_tickets organization.shared_tickets
        json.tags organization.tags.map(&:name)
      end
    end
  end,
  if @tickets.present?
    json.tickets do
      json.array!(@tickets) do |ticket|
        json._id ticket._id
        json.url ticket.url
        json.external_id ticket.external_id
        json.created_at ticket.created_at
        json.subject ticket.subject
        json.description ticket.description
        json.priority ticket.priority
        json.status ticket.status
        json.submitter_id ticket.submitter_id
        json.assignee_id ticket.assignee_id
        json.organization_id ticket.organization_id
        json.tags ticket.tags.map(&:name)
        json.has_incidents ticket.has_incidents
        json.due_at ticket.due_at
        json.via ticket.via
      end
    end
  end,
  if @users.present?
    json.users do
      json.array!(@users) do |user|
        json.id user.id
        json.url user.url
        json.external_id user.external_id
        json.name user.name
        json.alias user.alias
        json.created_at user.created_at
        json.active user.active
        json.verified user.verified
        json.shared user.shared
        json.locale user.locale
        json.timezone user.timezone
        json.last_login_at user.last_login_at
        json.email user.email
        json.phone user.phone
        json.signature user.signature
        json.organization_id user.organization_id
        json.tags user.tags.map(&:name)
        json.suspended user.suspended
        json.role user.role
      end
    end
  end
]
