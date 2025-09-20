import ballerina/http;
import ballerina/io;

// Define the same types as in service.bal
public enum Status {
    ACTIVE,
    UNDER_REPAIR,
    DISPOSED
}

public type Component record {|
    readonly string id;
    string name;
    string description;
    string installedDate;
|};

public type MaintenanceSchedule record {|
    readonly string scheduleId;
    string description;
    string frequency;
    string lastServiced;
    string nextDue;
|};

public type Task record {|
    readonly string taskId;
    string description;
    Status status;
    string assignedTo;
    string dueDate;
|};

public type WorkOrder record {|
    readonly string workOrderId;
    string title;
    string description;
    Status status;
    string openedDate;
    string closedDate?;
    Task[] tasks;
|};

public type Asset record {|
    readonly string assetTag;
    string name;
    string faculty;
    string department;
    Status status;
    string acquiredDate;
    Component[] components;
    MaintenanceSchedule[] schedules;
    WorkOrder[] workOrders;
|};

public function main() returns error? {
    http:Client assetClient = check new ("http://localhost:9090/nust/assets");

    io:println("== NUST Asset Management System Client Demo ===");

    // 1. Create a new asset
    io:println("\n1. Creating a new asset...");
    map<anydata> newAsset = {
        assetTag: "EQ-001",
        name: "3D Printer",
        faculty: "Computing & Informatics",
        department: "Software Engineering",
        status: "ACTIVE",
        acquiredDate: "2024-03-10",
        components: [],
        schedules: [],
        workOrders: []
    };

    http:Response createResponse = check assetClient->post("/", newAsset);
    io:println("Create Asset Response: " + createResponse.statusCode.toString() + " - " + createResponse.getTextPayload());

    // 2. Create another asset
    io:println("\n2. Creating another asset...");
    map<anydata> secondAsset = {
        assetTag: "SRV-001",
        name: "Web Server",
        faculty: "Computing & Informatics",
        department: "Computer Science",
        status: "ACTIVE",
        acquiredDate: "2024-01-15",
        components: [],
        schedules: [],
        workOrders: []
    };

    http:Response secondCreateResponse = check assetClient->post("/", secondAsset);
    io:println("Create Second Asset Response: " + secondCreateResponse.statusCode.toString() + " - " + secondCreateResponse.getTextPayload());

    // 3. Get all assets
    io:println("\n3. Getting all assets...");
    http:Response allAssetsResponse = check assetClient->get("/");
    if allAssetsResponse.statusCode == 200 {
        anydata assetsData = allAssetsResponse.getJsonPayload();
        io:println("Total assets retrieved successfully");
        if assetsData is Asset[] {
            io:println("Total assets: " + assetsData.length().toString());
            foreach var asset in assetsData {
                io:println(" - " + asset.assetTag.toString() + ": " + asset.name.toString());
            }
        }
    } else {
        io:println("Error: " + allAssetsResponse.getTextPayload());
    }

    // 4. Get assets by faculty
    io:println("\n4. Getting assets for Computing & Informatics faculty...");
    http:Response facultyResponse = check assetClient->get("/faculty/Computing & Informatics");
    if facultyResponse.statusCode == 200 {
        anydata facultyAssetsData = facultyResponse.getJsonPayload();
        io:println("Faculty assets retrieved successfully");
        if facultyAssetsData is Asset[] {
            io:println("Assets in faculty: " + facultyAssetsData.length().toString());
            foreach var asset in facultyAssetsData {
                io:println(" - " + asset.assetTag.toString() + ": " + asset.name.toString() + " (" + asset.department.toString() + ")");
            }
        }
    } else {
        io:println("Error: " + facultyResponse.getTextPayload());
    }

    // 5. Add a component to an asset
    io:println("\n5. Adding a component to EQ-001...");
    map<anydata> newComponent = {
        id: "COMP-001",
        name: "Print Head",
        description: "Main printing component",
        installedDate: "2024-03-10"
    };

    http:Response componentResponse = check assetClient->post("/EQ-001/components", newComponent);
    io:println("Add Component Response: " + componentResponse.statusCode.toString() + " - " + componentResponse.getTextPayload());

    // 6. Add a maintenance schedule
    io:println("\n6. Adding a maintenance schedule to EQ-001...");
    map<anydata> newSchedule = {
        scheduleId: "SCHED-001",
        description: "Quarterly maintenance",
        frequency: "QUARTERLY",
        lastServiced: "2024-03-10",
        nextDue: "2024-01-01" // Past date to test overdue
    };

    http:Response scheduleResponse = check assetClient->post("/EQ-001/schedules", newSchedule);
    io:println("Add Schedule Response: " + scheduleResponse.statusCode.toString() + " - " + scheduleResponse.getTextPayload());

    // 7. Check for overdue maintenance
    io:println("\n7. Checking for overdue maintenance items...");
    http:Response overdueResponse = check assetClient->get("/maintenance/overdue");
    if overdueResponse.statusCode == 200 {
        anydata overdueData = overdueResponse.getJsonPayload();
        io:println("Overdue maintenance check successful");
        if overdueData is Asset[] {
            io:println("Overdue assets: " + overdueData.length().toString());
            foreach var asset in overdueData {
                io:println(" - " + asset.assetTag.toString() + ": " + asset.name.toString());
            }
        }
    } else {
        io:println("No overdue items found: " + overdueResponse.getTextPayload());
    }

    // 8. Update an asset
    io:println("\n8. Updating EQ-001 status to UNDER_REPAIR...");
    map<anydata> updatedAsset = {
        assetTag: "EQ-001",
        name: "3D Printer",
        faculty: "Computing & Informatics",
        department: "Software Engineering",
        status: "UNDER_REPAIR",
        acquiredDate: "2024-03-10",
        components: [{
            id: "COMP-001",
            name: "Print Head",
            description: "Main printing component",
            installedDate: "2024-03-10"
        }],
        schedules: [{
            scheduleId: "SCHED-001",
            description: "Quarterly maintenance",
            frequency: "QUARTERLY",
            lastServiced: "2024-03-10",
            nextDue: "2024-06-10"
        }],
        workOrders: []
    };

    http:Response updateResponse = check assetClient->put("/EQ-001", updatedAsset);
    io:println("Update Asset Response: " + updateResponse.statusCode.toString() + " - " + updateResponse.getTextPayload());

    // 9. Get the updated asset
    io:println("\n9. Getting updated EQ-001 details...");
    http:Response getAssetResponse = check assetClient->get("/EQ-001");
    if getAssetResponse.statusCode == 200 {
        anydata assetData = getAssetResponse.getJsonPayload();
        if assetData is Asset {
            io:println("Asset: " + assetData.assetTag.toString() + ", Status: " + assetData.status.toString() + ", Components: " + assetData.components.length().toString());
        }
    } else {
        io:println("Error: " + getAssetResponse.getTextPayload());
    }

    io:println("\n=== Demo completed successfully ===");
    return;
}