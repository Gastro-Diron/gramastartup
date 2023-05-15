import ballerina/http;

service / on new http:Listener(9000) {

    resource function get users/[string email](http:Caller caller) returns error? {
        return getUser(email, caller);
    }

    resource function post documents(@http:Payload DocData document, http:Caller caller) returns error? {
        return postDocDetails(document, caller);
    }

    resource function get documents/user/[string email](http:Caller caller) returns error? {
        return getDocDetailsAsUser(email, caller);
    }

    resource function get documents/grama_sevaka/[string grama_sevaka_id](http:Caller caller) returns error? {
        return getDocDetailsAsGS(grama_sevaka_id, caller);
    }
}
