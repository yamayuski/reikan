spec module user;

import core.result;
import core.types;
import user.types;

// Public contract for the user service.
// Logic modules implement this contract; resource bindings inject the
// storage handle at startup time.
contract UserRepository {
    find(id: UserId) -> Result<User, UserError>;
    save(user: User) -> Result<Unit, UserError>;
    delete(id: UserId) -> Result<Unit, UserError>;
}

contract UserService {
    @[requires("name.len() > 0")]
    @[requires("age.into_inner() >= 18")]
    @[ensures("result.is_ok() implies result.unwrap().id.into_inner() > 0")]
    create(name: UserName, age: UserAge, email: UserEmail) -> Result<User, UserError>;

    find(id: UserId) -> Result<User, UserError>;
    update(id: UserId, patch: UserPatch) -> Result<User, UserError>;
    delete(id: UserId) -> Result<Unit, UserError>;
}
