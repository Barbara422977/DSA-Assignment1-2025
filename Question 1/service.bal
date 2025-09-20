import ballerina/http;
import ballerina/time;
import ballerina/io;

// Define enums and types
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

// Database table
table<Asset> key(assetTag) assets = table [];

// Service implementation
service /nust/assets on new http:Listener(9090) {

    // Create a new asset
    resource function post .(@http:Payload Asset asset) returns http:Response {
        if assets.hasKey(asset.assetTag) {
            http:Response res = new;
            res.statusCode = 400;
            res.setTextPayload("Asset with tag " + asset.assetTag + " already exists");
            return res;
        }
        assets.add(asset);
        http:Response res = new;
        res.statusCode = 201;
        res.setTextPayload("Asset created successfully: " + asset.assetTag);
        return res;
    }

    // Get all assets
    resource function get .() returns http:Response {
        if assets.length() == 0 {
            http:Response res = new;
            res.statusCode = 404;
            res.setTextPayload("No assets found");
            return res;
        }
        http:Response res = new;
        res.statusCode = 200;
        res.setJsonPayload(assets.toArray());
        return res;
    }

    // Get asset by tag
    resource function get ./[string assetTag]() returns http:Response {
        if assets.hasKey(assetTag) {
            http:Response res = new;
            res.statusCode = 200;
            res.setJsonPayload(assets.get(assetTag));
            return res;
        }
        http:Response res = new;
        res.statusCode = 404;
        res.setTextPayload("Asset not found: " + assetTag);
        return res;
    }

    // Update an asset
    resource function put ./[string assetTag](@http:Payload Asset updatedAsset) returns http:Response {
        if !assets.hasKey(assetTag) {
            http:Response res = new;
            res.statusCode = 404;
            res.setTextPayload("Asset not found: " + assetTag);
            return res;
        }

        if updatedAsset.assetTag != assetTag {
            http:Response res = new;
            res.statusCode = 400;
            res.setTextPayload("Asset tag cannot be changed");
            return res;
        }

        assets.remove(assetTag);
        assets.add(updatedAsset);
        http:Response res = new;
        res.statusCode = 200;
        res.setTextPayload("Asset updated successfully: " + assetTag);
        return res;
    }

    // Delete an asset
    resource function delete ./[string assetTag]() returns http:Response {
        if assets.hasKey(assetTag) {
            assets.remove(assetTag);
            http:Response res = new;
            res.statusCode = 200;
            res.setTextPayload("Asset deleted successfully: " + assetTag);
            return res;
        }
        http:Response res = new;
        res.statusCode = 404;
        res.setTextPayload("Asset not found: " + assetTag);
        return res;
    }

    // Get assets by faculty
    resource function get ./faculty/[string faculty]() returns http:Response {
        Asset[] facultyAssets = from var asset in assets
                              where asset.faculty == faculty
                              select asset;

        if facultyAssets.length() == 0 {
            http:Response res = new;
            res.statusCode = 404;
            res.setTextPayload("No assets found for faculty: " + faculty);
            return res;
        }
        http:Response res = new;
        res.statusCode = 200;
        res.setJsonPayload(facultyAssets);
        return res;
    }

    // Get overdue maintenance items
    resource function get ./maintenance/overdue() returns http:Response {
        string currentDate = time:utcNow().format("yyyy-MM-dd");
        Asset[] overdueAssets = [];

        foreach var asset in assets {
            foreach var schedule in asset.schedules {
                if schedule.nextDue < currentDate {
                    overdueAssets.push(asset);
                    break;
                }
            }
        }

        if overdueAssets.length() == 0 {
            http:Response res = new;
            res.statusCode = 404;
            res.setTextPayload("No overdue maintenance items found");
            return res;
        }
        http:Response res = new;
        res.statusCode = 200;
        res.setJsonPayload(overdueAssets);
        return res;
    }

    // Add component to asset
    resource function post ./[string assetTag]/components(@http:Payload Component component) returns http:Response {
        if assets.hasKey(assetTag) {
            Asset asset = assets.get(assetTag);
            asset.components.push(component);
            assets.remove(assetTag);
            assets.add(asset);
            http:Response res = new;
            res.statusCode = 201;
            res.setTextPayload("Component added to asset: " + assetTag);
            return res;
        }
        http:Response res = new;
        res.statusCode = 404;
        res.setTextPayload("Asset not found: " + assetTag);
        return res;
    }

    // Remove component from asset
    resource function delete ./[string assetTag]/components/[string componentId]() returns http:Response {
        if assets.hasKey(assetTag) {
            Asset asset = assets.get(assetTag);
            Component[] updatedComponents = [];
            boolean found = false;

            foreach var comp in asset.components {
                if comp.id != componentId {
                    updatedComponents.push(comp);
                } else {
                    found = true;
                }
            }

            if !found {
                http:Response res = new;
                res.statusCode = 404;
                res.setTextPayload("Component not found: " + componentId);
                return res;
            }
            asset.components = updatedComponents;
            assets.remove(assetTag);
            assets.add(asset);
            http:Response res = new;
            res.statusCode = 200;
            res.setTextPayload("Component removed from asset: " + assetTag);
            return res;
        }
        http:Response res = new;
        res.statusCode = 404;
        res.setTextPayload("Asset not found: " + assetTag);
        return res;
    }

    // Add maintenance schedule to asset
    resource function post ./[string assetTag]/schedules(@http:Payload MaintenanceSchedule schedule) returns http:Response {
        if assets.hasKey(assetTag) {
            Asset asset = assets.get(assetTag);
            asset.schedules.push(schedule);
            assets.remove(assetTag);
            assets.add(asset);
            http:Response res = new;
            res.statusCode = 201;
            res.setTextPayload("Schedule added to asset: " + assetTag);
            return res;
        }
        http:Response res = new;
        res.statusCode = 404;
        res.setTextPayload("Asset not found: " + assetTag);
        return res;
    }

    // Remove maintenance schedule from asset
    resource function delete ./[string assetTag]/schedules/[string scheduleId]() returns http:Response {
        if assets.hasKey(assetTag) {
            Asset asset = assets.get(assetTag);
            MaintenanceSchedule[] updatedSchedules = [];
            boolean found = false;

            foreach var sched in asset.schedules {
                if sched.scheduleId != scheduleId {
                    updatedSchedules.push(sched);
                } else {
                    found = true;
                }
            }
            if !found {
                http:Response res = new;
                res.statusCode = 404;
                res.setTextPayload("Schedule not found: " + scheduleId);
                return res;
            }

            asset.schedules = updatedSchedules;
            assets.remove(assetTag);
            assets.add(asset);
            http:Response res = new;
            res.statusCode = 200;
            res.setTextPayload("Schedule removed from asset: " + assetTag);
            return res;
        }
        http:Response res = new;
        res.statusCode = 404;
        res.setTextPayload("Asset not found: " + assetTag);
        return res;
    }

    // Add work order to asset
    resource function post ./[string assetTag]/workorders(@http:Payload WorkOrder workOrder) returns http:Response {
        if assets.hasKey(assetTag) {
            Asset asset = assets.get(assetTag);
            asset.workOrders.push(workOrder);
            assets.remove(assetTag);
            assets.add(asset);
            http:Response res = new;
            res.statusCode = 201;
            res.setTextPayload("Work order added to asset: " + assetTag);
            return res;
        }
        http:Response res = new;
        res.statusCode = 404;
        res.setTextPayload("Asset not found: " + assetTag);
        return res;
    }

    // Add task to work order
    resource function post ./[string assetTag]/workorders/[string workOrderId]/tasks(@http:Payload Task task) returns http:Response {
        if assets.hasKey(assetTag) {
            Asset asset = assets.get(assetTag);
            boolean workOrderFound = false;

            foreach var wo in asset.workOrders {
                if wo.workOrderId == workOrderId {
                    wo.tasks.push(task);
                    workOrderFound = true;
                    break;
                }
            }
            if !workOrderFound {
                http:Response res = new;
                res.statusCode = 404;
                res.setTextPayload("Work order not found: " + workOrderId);
                return res;
            }
            assets.remove(assetTag);
            assets.add(asset);
            http:Response res = new;
            res.statusCode = 201;
            res.setTextPayload("Task added to work order: " + workOrderId);
            return res;
        }
        http:Response res = new;
        res.statusCode = 404;
        res.setTextPayload("Asset not found: " + assetTag);
        return res;
    }
}