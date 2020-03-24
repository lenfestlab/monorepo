class UserResource < JSONAPI::Resource
  attributes(*%i[email created_at updated_at])
end
