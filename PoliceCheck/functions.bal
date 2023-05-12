import ballerinax/mongodb;
import ballerina/http;

configurable string username = ?;
configurable string password = ?;
configurable string databaseName = ?;
configurable string collection = ?;

final mongodb:Client mongoClient = check new ({connection: {url: string `mongodb+srv://${username}:${password}@gramacheckcluster.used77d.mongodb.net/`}});

public type CrimeRecord record {|
    string email;
    string description;
    int severity;
|};

type IDjson record {
};

public type FullCrimeRecord record {|
    *CrimeRecord;
    IDjson _id;
|};

isolated function addRecord(CrimeRecord userData, http:Caller caller) returns error? {

    http:Response response = new;
    int count = check mongoClient->countDocuments(collection,databaseName,{email:userData.email, description:userData.description});

    if count == 0 {
        check mongoClient->insert(userData,collection,databaseName);
        response.statusCode = 201;
        response.setJsonPayload({status:"success", description:"Crime record has been added successfully"});
    } else {
        int updatedDocsCount = check mongoClient->update({"$set":{severity:userData.severity}},collection,databaseName,({email:userData.email, description:userData.description}));
        response.statusCode = 200;
        response.setJsonPayload({status:"success", description:"Crime Record has been updated successfully"});
    }

    check caller->respond(response);
    return;
}

isolated function getRecord (string email, http:Caller caller) returns error? {
    http:Response response = new;
    FullCrimeRecord[] crimeRecordsList = [];
    boolean isGuilt = false;

    stream<FullCrimeRecord, error?> crimeRecordsStream = check mongoClient->find(collectionName = collection, databaseName = databaseName, filter = ({"email":email}));
    check from FullCrimeRecord entry in crimeRecordsStream
        do {
             crimeRecordsList.push(entry);
        };
    check crimeRecordsStream.close();

    if (crimeRecordsList.length() == 0){
        response.statusCode = 404;
        response.setJsonPayload({status:"failure", description:"No user exists with the given email"});
    } else {
        foreach FullCrimeRecord item in crimeRecordsList {
            if (item.severity >= 5) {
                isGuilt = true;
                break;
            } else {
                continue;
            }
        }

        if isGuilt {
            response.statusCode = 200;
            response.setJsonPayload({status:"success", description:"User's crime Records have been checked", isGuilt:true});
        } else {
            response.statusCode = 200;
            response.setJsonPayload({status:"success", description:"User's crime Records have been checked", isGuilt:false});
        }
    }

    check caller->respond(response);
    return;
}

isolated function deleteUser(string email, http:Caller caller) returns error? {

    http:Response response = new;
    int count = check mongoClient->countDocuments(collection,databaseName,{email:email});

    if count == 0 {
        response.statusCode = 404;
        response.setJsonPayload({status:"failure", description:"No user exists with the given email"});
    } else {
        int deletedDocsCount = check mongoClient->delete(collection,databaseName,({email:email}),true);
        response.statusCode = 200;
        response.setJsonPayload({status:"success", description:"User has been deleted successfully"});
    }

    check caller->respond(response);
    return;
}

isolated function deleteRecord(string email, string description, http:Caller caller) returns error? {

    http:Response response = new;
    int count = check mongoClient->countDocuments(collection,databaseName,{email:email, description:description});

    if count == 0 {
        response.statusCode = 404;
        response.setJsonPayload({status:"failure", description:"No such record exists for the email"});
    } else {
        int deletedDocsCount = check mongoClient->delete(collection,databaseName,({email:email, description:description}),true);
        response.statusCode = 200;
        response.setJsonPayload({status:"success", description:"Crime Record has been deleted successfully"});
    }

    check caller->respond(response);
    return;
}