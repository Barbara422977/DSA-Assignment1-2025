import ballerina/http;
import ballerina/time;
import ballerina/log;

// Asset Management System Data Types
listener http:Listener assetService = new (9090);

public type AssetStatus "ACTIVE"|"UNDER_REPAIR"|"DISPOSED";

public type Asset record {
    string assetTag;
    string name;
    string faculty;
    string department;
    AssetStatus status;
    string acquiredDate;
    map<Component> components;
    map<Schedule> schedules;
    map<WorkOrder> workOrders;
};

public type Component record {
    string componentId;
    string name;
    string description;
    string status;
};

public type Schedule record {
    string scheduleId;
    string name;
    string frequency;
    string nextDueDate;
    string description;
};

public type WorkOrder record {
    string workOrderId;
    string description;
    string status;
    string createdDate;
    string? completedDate;
    map<Task> tasks;
};

public type Task record {
    string taskId;
    string description;
    string status;
    string? assignedTo;
};

// MAP-ONLY DATABASE
map<Asset> assetDatabase = {};

// NUST ASSET MANAGEMENT SERVICE
service /assets on new http:Listener(8080) {

    // CREATE ASSET (10 marks - part 1)
    resource function post .(@http:Payload Asset asset) returns http:Created|http:BadRequest {
        Asset? existing = assetDatabase[asset.assetTag];
        if existing is Asset {
            return http:BAD_REQUEST;
        }
        assetDatabase[asset.assetTag] = asset;
        log:printInfo("Created asset: " + asset.assetTag);
        return http:CREATED;
    }

    // LOOKUP ASSET (10 marks - part 2)
    resource function get [string assetTag]() returns Asset|http:NotFound {
        Asset? asset = assetDatabase[assetTag];
        if asset is Asset {
            return asset;
        }
        return http:NOT_FOUND;
    }

    // UPDATE ASSET (10 marks - part 3)
    resource function put [string assetTag](@http:Payload Asset asset) returns http:Ok|http:NotFound|http:BadRequest {
        Asset? existing = assetDatabase[assetTag];
        if existing is () {
            return http:NOT_FOUND;
        }
        if assetTag != asset.assetTag {
            return http:BAD_REQUEST;
        }
        assetDatabase[assetTag] = asset;
        log:printInfo("Updated asset: " + assetTag);
        return http:OK;
    }

    // DELETE ASSET (10 marks - part 4)
    resource function delete [string assetTag]() returns http:NoContent|http:NotFound {
        Asset? asset = assetDatabase[assetTag];
        if asset is () {
            return http:NOT_FOUND;
        }
        _ = assetDatabase.remove(assetTag);
        log:printInfo("Deleted asset: " + assetTag);
        return http:NO_CONTENT;
    }

    // VIEW ALL ASSETS (3 marks)
    resource function get .() returns Asset[] {
        Asset[] allAssets = [];
        string[] keys = assetDatabase.keys();
        foreach string key in keys {
            Asset? asset = assetDatabase[key];
            if asset is Asset {
                allAssets.push(asset);
            }
        }
        return allAssets;
    }

    // VIEW BY FACULTY (5 marks)
    resource function get faculty/[string facultyName]() returns Asset[] {
        Asset[] facultyAssets = [];
        string[] keys = assetDatabase.keys();
        foreach string key in keys {
            Asset? asset = assetDatabase[key];
            if asset is Asset && asset.faculty == facultyName {
                facultyAssets.push(asset);
            }
        }
        return facultyAssets;
    }

    // CHECK OVERDUE (5 marks)
    resource function get overdue() returns Asset[] {
        Asset[] overdueAssets = [];
        time:Utc currentTime = time:utcNow();
        string currentDateString = time:utcToString(currentTime);
        string currentDate = currentDateString.substring(0, 10);
        
        string[] assetKeys = assetDatabase.keys();
        foreach string assetKey in assetKeys {
            Asset? asset = assetDatabase[assetKey];
            if asset is Asset {
                string[] scheduleKeys = asset.schedules.keys();
                boolean hasOverdue = false;
                foreach string scheduleKey in scheduleKeys {
                    Schedule? schedule = asset.schedules[scheduleKey];
                    if schedule is Schedule && schedule.nextDueDate < currentDate {
                        hasOverdue = true;
                        break;
                    }
                }
                if hasOverdue {
                    overdueAssets.push(asset);
                }
            }
        }
        return overdueAssets;
    }

    // MANAGE COMPONENTS (5 marks)
    // Add component
    resource function post [string assetTag]/components(@http:Payload Component component) returns http:Created|http:NotFound {
        Asset? asset = assetDatabase[assetTag];
        if asset is () {
            return http:NOT_FOUND;
        }
        asset.components[component.componentId] = component;
        assetDatabase[assetTag] = asset;
        log:printInfo("Added component " + component.componentId);
        return http:CREATED;
    }

    // Get components
    resource function get [string assetTag]/components() returns Component[]|http:NotFound {
        Asset? asset = assetDatabase[assetTag];
        if asset is () {
            return http:NOT_FOUND;
        }
        Component[] components = [];
        string[] keys = asset.components.keys();
        foreach string key in keys {
            Component? comp = asset.components[key];
            if comp is Component {
                components.push(comp);
            }
        }
        return components;
    }

    // Remove component
    resource function delete [string assetTag]/components/[string componentId]() returns http:NoContent|http:NotFound {
        Asset? asset = assetDatabase[assetTag];
        if asset is () {
            return http:NOT_FOUND;
        }
        Component? comp = asset.components[componentId];
        if comp is () {
            return http:NOT_FOUND;
        }
        _ = asset.components.remove(componentId);
        assetDatabase[assetTag] = asset;
        log:printInfo("Removed component " + componentId);
        return http:NO_CONTENT;
    }

    // MANAGE SCHEDULES (5 marks)
    // Add schedule
    resource function post [string assetTag]/schedules(@http:Payload Schedule schedule) returns http:Created|http:NotFound {
        Asset? asset = assetDatabase[assetTag];
        if asset is () {
            return http:NOT_FOUND;
        }
        asset.schedules[schedule.scheduleId] = schedule;
        assetDatabase[assetTag] = asset;
        log:printInfo("Added schedule " + schedule.scheduleId);
        return http:CREATED;
    }

    // Get schedules
    resource function get [string assetTag]/schedules() returns Schedule[]|http:NotFound {
        Asset? asset = assetDatabase[assetTag];
        if asset is () {
            return http:NOT_FOUND;
        }
        Schedule[] schedules = [];
        string[] keys = asset.schedules.keys();
        foreach string key in keys {
            Schedule? sched = asset.schedules[key];
            if sched is Schedule {
                schedules.push(sched);
            }
        }
        return schedules;
    }

    // Remove schedule
    resource function delete [string assetTag]/schedules/[string scheduleId]() returns http:NoContent|http:NotFound {
        Asset? asset = assetDatabase[assetTag];
        if asset is () {
            return http:NOT_FOUND;
        }
        Schedule? sched = asset.schedules[scheduleId];
        if sched is () {
            return http:NOT_FOUND;
        }
        _ = asset.schedules.remove(scheduleId);
        assetDatabase[assetTag] = asset;
        log:printInfo("Removed schedule " + scheduleId);
        return http:NO_CONTENT;
    }
}
