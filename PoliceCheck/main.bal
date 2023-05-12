import ballerina/http;

service /police on new http:Listener(9000) {

    isolated resource function post records(@http:Payload CrimeRecord userData, http:Caller caller) returns error? {
        return addRecord(userData, caller);
    }

    resource function get severity/[string email](http:Caller caller) returns error? {
        return getRecord(email, caller);
    }

    resource function delete records/[string email](http:Caller caller) returns error? {
        return deleteUser(email, caller);
    }

    resource function delete records/[string email]/[string description] (http:Caller caller) returns error? {
        return deleteRecord(email, description, caller);
    }
}



