import ballerinax/mongodb;
import ballerina/http;

configurable string username = ?;
configurable string password = ?;
string databaseName = "gramaCheckDB";
string collection = "";

final mongodb:Client mongoClient = check new ({connection: {url: string `mongodb+srv://${username}:${password}@gramacheckcluster.used77d.mongodb.net/`}});

public type DocData record {|
    string document_id;
    string email;
    string document_type;
    string status;
    string grama_sevaka_id;
|};

public type IDjson record {
};

public type FullDocData record {|
    *DocData;
    IDjson _id;
|};

public type User record {|
    string email;
    string first_name;
    string last_name;
    string nic;
    string[] address;
    string gramasevaka_area;
    string phone_num;
|};

public type FullUser record {|
    *User;
    IDjson _id;
|};

function getUser (string email, http:Caller caller) returns error? {
    collection = "public_user";
    http:Response response = new;
    FullUser[] userList = [];

    stream<FullUser, error?> userStream = check mongoClient->find(collectionName = collection, databaseName = databaseName, filter = ({"email":email}));
    check from FullUser entry in userStream
        do {
             userList.push(entry);
        };
    check userStream.close();

    if (userList.length() == 0){
        response.statusCode = 404;
        response.setJsonPayload({status:"failure", description:"No user exists with the email"});
    } else {
        response.statusCode = 200;
        response.setJsonPayload({status:"success", description:"The user has been returned", user:userList.toJson()});
    }

    check caller->respond(response);
    return;
}

function postDocDetails(DocData document, http:Caller caller) returns error? {
    collection = "Documents";

    http:Response response = new;
    int count = check mongoClient->countDocuments(collection,databaseName,{email:document.email, document_type:document.document_type});

    if count == 0 {
        check mongoClient->insert(document,collection,databaseName);
        response.statusCode = 201;
        response.setJsonPayload({status:"success", description:"Document details has been added successfully"});
    } else {
        int updatedDocsCount = check mongoClient->update({"$set":{status:document.status}},collection,databaseName,({email:document.email, document_type:document.document_type}));
        response.statusCode = 201;
        response.setJsonPayload({status:"success", description:"Document details has been updated successfully"});
    }

    check caller->respond(response);
    return;
}

function getDocDetailsAsUser (string email, http:Caller caller) returns error? {
    collection = "Documents";
    http:Response response = new;
    FullDocData[] documentsList = [];

    stream<FullDocData, error?> documentsStream = check mongoClient->find(collectionName = collection, databaseName = databaseName, filter = ({"email":email}));
    check from FullDocData entry in documentsStream
        do {
             documentsList.push(entry);
        };
    check documentsStream.close();

    if (documentsList.length() == 0){
        response.statusCode = 404;
        response.setJsonPayload({status:"failure", description:"No user exists with the given email"});
    } else {
        response.statusCode = 200;
        response.setJsonPayload({status:"success", description:"The documents list has been returned", documents:documentsList.toJson()});
    }

    check caller->respond(response);
    return;
}

function getDocDetailsAsGS (string grama_sevaka_id, http:Caller caller) returns error? {
    collection = "Documents";
    http:Response response = new;
    FullDocData[] documentsList = [];

    stream<FullDocData, error?> documentsStream = check mongoClient->find(collectionName = collection, databaseName = databaseName, filter = ({"grama_sevaka_id":grama_sevaka_id}));
    check from FullDocData entry in documentsStream
        do {
             documentsList.push(entry);
        };
    check documentsStream.close();

    if (documentsList.length() == 0){
        response.statusCode = 404;
        response.setJsonPayload({status:"failure", description:"Invalid Grama Sevaka ID"});
    } else {
        response.statusCode = 200;
        response.setJsonPayload({status:"success", description:"The documents list has been returned", documents:documentsList.toJson()});
    }

    check caller->respond(response);
    return;
}