JSONAPI.configure do |config|

  key_format = :underscored_key
  config.json_key_format = key_format
  config.route_format = key_format

  config.always_include_to_one_linkage_data = true
  config.always_include_to_many_linkage_data = true

  config.top_level_meta_include_record_count = true
  config.top_level_meta_record_count_key = :total

  # NOTE: whitelist exceptions for passing to exception service
  config.whitelist_all_exceptions = true

  # TODO: fix client serializer bug that bakes :id into :attributes on PATCH
  config.raise_if_parameters_not_allowed = false

  config.default_paginator = :paged
end
