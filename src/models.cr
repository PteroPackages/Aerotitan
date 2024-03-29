module Aero::Models
  alias Fields = Hash(String, Template::Value.class)

  USER_FIELDS = {
    "user.2fa"         => Template::BoolLiteral,
    "user.created_at"  => Template::StringLiteral,
    "user.email"       => Template::StringLiteral,
    "user.external_id" => Template::NullableString,
    "user.first_name"  => Template::StringLiteral,
    "user.id"          => Template::NumberLiteral,
    "user.language"    => Template::StringLiteral,
    "user.last_name"   => Template::StringLiteral,
    "user.root_admin"  => Template::BoolLiteral,
    "user.updated_at"  => Template::NullableString,
    "user.username"    => Template::StringLiteral,
    "user.uuid"        => Template::StringLiteral,
  }.as Fields

  SERVER_FIELDS = {
    "server.id"          => Template::NumberLiteral,
    "server.external_id" => Template::NullableString,
    "server.uuid"        => Template::StringLiteral,
    "server.identifier"  => Template::StringLiteral,
    "server.name"        => Template::StringLiteral,
    "server.description" => Template::NullableString,
    "server.status"      => Template::NullableString,
    "server.suspended"   => Template::BoolLiteral,
    "server.user"        => Template::NumberLiteral,
    "server.node"        => Template::NumberLiteral,
    "server.allocation"  => Template::NumberLiteral,
    "server.nest"        => Template::NumberLiteral,
    "server.egg"         => Template::NumberLiteral,
    "server.created_at"  => Template::StringLiteral,
    "server.updated_at"  => Template::NullableString,
  }.as Fields
end
