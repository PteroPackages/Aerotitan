module Aerotitan::Models
  alias Info = Hash(String, Syntax::Literal.class)

  USER = {
    "2fa" => Syntax::BoolLiteral,
    "created_at" => Syntax::StringLiteral,
    "email" => Syntax::StringLiteral,
    "external_id" => Syntax::NullableString,
    "first_name" => Syntax::StringLiteral,
    "id" => Syntax::NumberLiteral,
    "language" => Syntax::StringLiteral,
    "last_name" => Syntax::StringLiteral,
    "root_admin" => Syntax::BoolLiteral,
    "updated_at" => Syntax::NullableString,
    "username" => Syntax::StringLiteral,
    "uuid" => Syntax::StringLiteral
  }.as(Info)
end
