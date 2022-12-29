module Aerotitan::Models
  alias Info = Hash(String, Syntax::ValueRef.class)

  USER = {
    "user.2fa"         => Syntax::BoolLiteral,
    "user.created_at"  => Syntax::StringLiteral,
    "user.email"       => Syntax::StringLiteral,
    "user.external_id" => Syntax::NullableString,
    "user.first_name"  => Syntax::StringLiteral,
    "user.id"          => Syntax::NumberLiteral,
    "user.language"    => Syntax::StringLiteral,
    "user.last_name"   => Syntax::StringLiteral,
    "user.root_admin"  => Syntax::BoolLiteral,
    "user.updated_at"  => Syntax::NullableString,
    "user.username"    => Syntax::StringLiteral,
    "user.uuid"        => Syntax::StringLiteral,
  }.as(Info)
end
