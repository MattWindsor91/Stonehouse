Rapier.Obgen.Php.Types
======================

This module collates the algebraic data types that abstractly define
the subset of PHP we use to implement Rapier objects.

> module Rapier.Obgen.Php.Types where

Type synonyms
-------------

A class name is just a string.

> type ClassName = String

As is a namespace.

> type Namespace = String

And an author name...

> type AuthorName = String

...and an email address...

> type Email = String

...and an identifier (variable name)

> type Identifier = String


Data types
----------

A PHP program is a list of statements.

> data Php = PhpStatementList [PhpStatement]
>          deriving ( Show, Read )

***

Inheritance in PHP is either "extends" (which implies inheriting from
a parent class) or "implements" (inheriting from an interface).

> data Inheritance = Extends String
>                  | Implements String
>                  | DoesNotInherit
>                  deriving ( Show, Read )

***

For the purposes of Obgen, an outside-of-class PHP statement is a
comment, a namespace declaration, an include or a class.

(Obviously, this doesn't capture the full breadth of the PHP language;
we're just implementing a safe subset that we can use to generate
objects.)

> data PhpStatement = CommentStatement PhpComment
>                   | NamespaceStatement Namespace
>                   | RequireOnceStatement String
>                     -- Filename to be required
>                   | PhpClass String Inheritance
>                     [ PhpClassStatement ]
>                     -- Name, inheritance and body
>                   deriving ( Show, Read )

***

Inside a class, Obgen expects methods and fields.

> data PhpClassStatement = PhpClassComment PhpComment
>                        | PhpClassMethod PhpMethod
>                        | PhpClassField PhpField
>                          deriving ( Show, Read )

***

A field is a constant, a visibility-qualified variable, or a
visibility-qualified static variable.  Consts must be initialised to
an expression; vars do not (they will be initialised in the
constructor).

> data PhpField = Const String String
>               | StaticVar Visibility String (Maybe PhpExpr)
>                 -- Visibility, name, optional assignment
>               | Var Visibility String (Maybe PhpExpr)
>                 -- Visibility, name, optional assignment
>                 deriving ( Show, Read )

Methods
-------

A method is a static method or a normal method.  Both have a name, and
a set of statements inside them.

> data PhpMethod =
>     StaticMethod Visibility String [ Param ] [ PhpMethodStatement ]
>                  -- Visibility, name, parameters, body
>         | Method Visibility String [ Param ] [ PhpMethodStatement ]
>                  -- As above
>           deriving ( Show, Read )

***

A method parameter is an enjoinment of an identifier and a type.  (The
type is, at time of writing, usually dropped, but hopefully one day
PHP's parameter type checking will get better!)

> data Param = PhpType :$ Identifier
>              deriving ( Show, Read )

> infixr 5 :$

***

A method statement, as far as we're concerned for this subset of PHP,
can be a function call, a method call, or a comment.

> data PhpMethodStatement = NakedExpr PhpExpr
>                         | InMethodComment PhpComment
>                         | Identifier := PhpExpr
>                         | Return PhpExpr
>                           deriving ( Show, Read )

***

Let's define a (workable subset of) a PHP expression.

> data PhpExpr = IdExpr Identifier
>              | IntLiteral Integer
>              | SingleQuotedString String
>              | DoubleQuotedString String
>              | FunctionCallExpr String [ PhpExpr ]
>              | ArrayExpr [ ArrayItem ]
>              | New ClassName [ PhpExpr ]
>              | ArraySubscript Identifier PhpExpr
>                deriving ( Show, Read )

***

> data ArrayItem = ImplicitKey PhpExpr
>                | PhpExpr :=>: PhpExpr -- LHS is key, RHS value
>                  deriving ( Show, Read )

> infixr 5 :=>:

***

Visibility is public, protected or private.

> data Visibility = Public | Protected | Private
>                   deriving ( Show, Read )

***

These are organised into a list, so they can be properly formatted.

> data DocCommentItem = DcParamList [ DcParam ]

Return type and comment

>                     | DcReturn PhpType String
>                     | DcCategory String
>                     | DcPackage Namespace
>                     | DcLink String
>                     | DcAuthor AuthorName Email

URI and description of licence

>                     | DcLicence String String
>                     deriving ( Show, Read )

**

Type, name and comment

> data DcParam = CommentedParam PhpType String String
>              deriving ( Show, Read )

***

> data PhpComment = LineComment String
>                 | BlockComment String
> -- Brief, details and comment items
>                 | DocComment String
>                   ( Maybe String ) [ DocCommentItem ]
>                 deriving ( Show, Read )

PHP types
---------

Following is an enumeration of all the possible PHP types.

> data PhpType = PString
>              | PInteger
>              | PBool
>              | PCallback
>              | PDouble
>              | PMixed
>              | PArray
>              | PObject String
>                deriving ( Show, Read, Eq )
