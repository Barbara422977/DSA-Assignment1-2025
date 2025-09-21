import ballerina/http;
import ballerina/io;

http:Client assetClient = check new ("http://localhost:8080");

public function main() returns error? {
    check testClient();
}

public function testClient() returns error? {
    io:println("=== NUST ASSET MANAGEMENT CLIENT TEST ===\n");

    // Test data
    json asset1 = {
        "assetTag": "DA-001",
        "name": "8D Printer",
        "faculty": "Computing & Informatics",
        "department": "Computer Science",
        "status": "ACTIVE",
        "acquiredDate": "2023-03-10",
        "components": {},
        "schedules": {},
        "workOrders": {}
    };
    

    // 1. CREATE ASSET
    io:println("1. Creating Asset...");
    http:Response createResp = check assetClient->post("/assets", asset1);
    io:println("✓ Created: " + createResp.statusCode.toString());

    // 2. VIEW ALL ASSETS
    io:println("\n2. View All Assets...");
    json allAssets = check assetClient->get("/assets");
    io:println("Retrieved all assets: ", allAssets.toJsonString());

    // 3. ADD COMPONENT
    io:println("\n3. Adding Component...");
    json component = {
        "componentId": "COM-009",
        "name": "Print Young",
        "description": "High precision",
        "status": "ACTIVE"
    };
    http:Response compResp = check assetClient->post("/assets/DA-001/components", component);
    io:println("✓ Added component: " + compResp.statusCode.toString());

    // 4. ADD OVERDUE SCHEDULE
    io:println("\n4. Adding Overdue Schedule...");
    json schedule = {
        "scheduleId": "SCH-010",
        "name": "Maintenance",
        "frequency": "quarterly",
        "nextDueDate": "2023-02-15",
        "description": "Regular check"
    };
    http:Response schedResp = check assetClient->post("/assets/DA-001/schedules", schedule);
    io:println("Added schedule: " + schedResp.statusCode.toString());

    // 5. CHECK OVERDUE
    io:println("\n5. Check Overdue...");
    json overdueAssets = check assetClient->get("/assets/overdue");
    io:println("Found overdue assets: ", overdueAssets.toJsonString());

    // 6. VIEW BY FACULTY
    io:println("\n6. View by Faculty...");
    string faculty = "Computing & Informatics";
    string facultyEncoded = urlEncode(faculty); // use helper function
    json facultyAssets = check assetClient->get("/assets/faculty/" + facultyEncoded);
    io:println("Faculty assets retrieved: ", facultyAssets.toJsonString());

    io:println("\n=== ALL TESTS COMPLETED SUCCESSFULLY! ===");
}

// ------------------------------
// URL Encode Helper Function
// ------------------------------
function urlEncode(string input) returns string {
    string encoded = "";
    foreach int i in 0 ..< input.length() {
        string c = input.substring(i, i + 1);
        if (c == " ") {
            encoded += "%20";
        } else if (c == "&") {
            encoded += "%26";
        } else {
            encoded += c;
        }
    }
    return encoded;
}
