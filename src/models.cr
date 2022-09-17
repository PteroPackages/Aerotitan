module Aerotitan::Models
  alias Info = Hash(String, Syntax::Literal)

  USER : Info = {
    "2fa" => Syntax::BooleanLiteral,
    "created_at" => Syntax::StringLiteral,
    "email" => Syntax::StringLiteral,
    "external_id" => Syntax::NullableString,
    "first_name" => Syntax::StringLiteral,
    "id" => Syntax::NumberLiteral,
    "language" => Syntax::StringLiteral,
    "last_name" => Syntax::StringLiteral,
    "root_admin" => Syntax::BooleanLiteral,
    "updated_at" => Syntax::NullableString,
    "username" => Syntax::StringLiteral,
    "uuid" => Syntax::StringLiteral
  }
end
