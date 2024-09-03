import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Iter "mo:base/Iter";

actor class Backend() {
  type User = {
    id : Text;
    username : Text;
    password : Nat32;
  };

  var users = HashMap.HashMap<Text, User>(0, Text.equal, Text.hash);

  stable var userArray : [(Text, User)] = [];

  public func register(username : Text, password : Text, id : Text) : async Text {
    if (users.get(id) == null) {

      let newUser : User = {
        id = id;
        username = username;
        password = Text.hash(password);
      };

      users.put(username, newUser);
      return Nat32.toText(Text.hash(username));
    };
    return "User already exists.";
  };

  public func login(username : Text, password : Text) : async Nat {
    switch (users.get(username)) {
      case (null) {
        return 404;
      };
      case (?user) {
        if (user.password == Text.hash(password)) {
          return 200;
        } else {
          return 401;
        };
      };
    };
  };

  system func preupgrade() {
    userArray := Iter.toArray(users.entries());
  };

  system func postupgrade() {
    users := HashMap.fromIter<Text, User>(userArray.vals(), 0, Text.equal, Text.hash);
  };

};
