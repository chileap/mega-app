class AccountRecord < ApplicationRecord
  # Inherit from this class to add ActsAsTenant multitenancy enforcement to a model.
  # You can also add any workspace / multitenancy helpers here to be shared across your multitenant models.

  self.abstract_class = true

  acts_as_tenant :workspace
end
