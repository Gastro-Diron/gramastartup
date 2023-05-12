import ballerina/http;

service /police on new http:Listener(9000) {

    isolated resource function post records(@http:Payload CrimeRecord userData, http:Caller caller) returns error? {
        return addRecord(userData, caller);
    }

    resource function get severity/[string email](http:Caller caller) returns error? {
        return getRecord(email, caller);
    }
}



