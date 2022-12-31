module Aerotitan::Models
  alias Info = Hash(String, Template::Value.class)

  USER = {
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
  }.as(Info)
end
