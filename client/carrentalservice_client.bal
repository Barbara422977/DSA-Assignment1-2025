import ballerina/io;

CarRentalServiceClient ep = check new ("http://localhost:9090");

public function main() returns error? {
    
    io:println("=== CAR RENTAL SYSTEM CLIENT TEST ===\n");

    // First, create a user to test with
    io:println("1. Creating test users...");
    User adminUser = {
        user_id: "admin1", 
        name: "Test Admin", 
        email: "admin@test.com", 
        phone: "+1234567890", 
        role: ADMIN, 
        address: "123 Admin St", 
        license_number: "ADMIN001", 
        age: 30
    };
    
    User customerUser = {
        user_id: "customer1", 
        name: "Test Customer", 
        email: "customer@test.com", 
        phone: "+0987654321", 
        role: CUSTOMER, 
        address: "456 Customer Ave", 
        license_number: "CUST001", 
        age: 25
    };
    
    // Create users using streaming
    CreateUsersStreamingClient createUsersStreamingClient = check ep->CreateUsers();
    check createUsersStreamingClient->sendUser(adminUser);
    check createUsersStreamingClient->sendUser(customerUser);
    check createUsersStreamingClient->complete();
    CreateUsersResponse? createUsersResponse = check createUsersStreamingClient->receiveCreateUsersResponse();
    io:println("Create Users Response: ", createUsersResponse);
    
    // 2. Add a car (corrected with proper enum values)
    io:println("\n2. Adding a test car...");
    Car addCarRequest = {
        plate: "TEST123", 
        make: "Toyota", 
        model: "Camry", 
        year: 2023, 
        daily_price: 50.0, 
        mileage: 10000, 
        status: AVAILABLE,  // Using enum, not string
        description: "Test car for demonstration", 
        color: "Blue", 
        fuel_type: "Gasoline"
    };
    AddCarResponse addCarResponse = check ep->AddCar(addCarRequest);
    io:println("Add Car Response: ", addCarResponse);

    // 3. Update the car
    io:println("\n3. Updating the car...");
    Car updatedCarData = {
        plate: "TEST123", 
        make: "Toyota", 
        model: "Camry", 
        year: 2023, 
        daily_price: 55.0,  // Price increase
        mileage: 10500,     // Updated mileage
        status: AVAILABLE, 
        description: "Updated test car with new price", 
        color: "Blue", 
        fuel_type: "Gasoline"
    };
    UpdateCarRequest updateCarRequest = {
        plate: "TEST123", 
        updated_car: updatedCarData
    };
    UpdateCarResponse updateCarResponse = check ep->UpdateCar(updateCarRequest);
    io:println("Update Car Response: ", updateCarResponse);

    // 4. Search for the car
    io:println("\n4. Searching for the car...");
    SearchCarRequest searchCarRequest = {
        plate: "TEST123", 
        customer_id: "customer1"
    };
    SearchCarResponse searchCarResponse = check ep->SearchCar(searchCarRequest);
    io:println("Search Car Response: ", searchCarResponse);

    // 5. List available cars
    io:println("\n5. Listing available cars...");
    ListAvailableCarsRequest listAvailableCarsRequest = {
        customer_id: "customer1", 
        filter_text: "", 
        filter_year: 0, 
        max_price: 0.0, 
        fuel_type: ""
    };
    stream<Car, error?> listAvailableCarsResponse = check ep->ListAvailableCars(listAvailableCarsRequest);
    io:println("Available Cars:");
    check listAvailableCarsResponse.forEach(function(Car value) {
        io:println("  - ", value.plate, ": ", value.make, " ", value.model, " ($", value.daily_price, "/day)");
    });

    // 6. Add car to cart (with proper date format)
    io:println("\n6. Adding car to cart...");
    AddToCartRequest addToCartRequest = {
        customer_id: "customer1", 
        plate: "TEST123", 
        start_date: "2024-04-15",  // Proper date format
        end_date: "2024-04-20"     // Proper date format
    };
    AddToCartResponse addToCartResponse = check ep->AddToCart(addToCartRequest);
    io:println("Add to Cart Response: ", addToCartResponse);

    // 7. Get cart contents
    io:println("\n7. Getting cart contents...");
    GetCartRequest getCartRequest = {customer_id: "customer1"};
    GetCartResponse getCartResponse = check ep->GetCart(getCartRequest);
    io:println("Get Cart Response: ", getCartResponse);

    // 8. Place reservation
    io:println("\n8. Placing reservation...");
    PlaceReservationRequest placeReservationRequest = {
        customer_id: "customer1", 
        payment_method: "Credit Card", 
        special_requests: "Please ensure car is clean"
    };
    PlaceReservationResponse placeReservationResponse = check ep->PlaceReservation(placeReservationRequest);
    io:println("Place Reservation Response: ", placeReservationResponse);

    // 9. List all reservations (admin operation)
    io:println("\n9. Listing all reservations (admin view)...");
    ListReservationsRequest listAllReservationsRequest = {
        admin_id: "admin1", 
        filter_status: "", 
        start_date: "", 
        end_date: ""
    };
    stream<Reservation, error?> listAllReservationsResponse = check ep->ListAllReservations(listAllReservationsRequest);
    io:println("All Reservations:");
    check listAllReservationsResponse.forEach(function(Reservation value) {
        io:println("  - Reservation ID: ", value.reservation_id);
        io:println("    Customer: ", value.customer_name);
        io:println("    Car: ", value.car_info, " (", value.plate, ")");
        io:println("    Dates: ", value.start_date, " to ", value.end_date);
        io:println("    Price: $", value.total_price);
        io:println("    Status: ", value.status);
        io:println();
    });

    // 10. Try to remove the car (should fail because it's rented)
    io:println("\n10. Attempting to remove rented car (should fail)...");
    RemoveCarRequest removeCarRequest = {
        plate: "TEST123", 
        admin_id: "admin1"
    };
    RemoveCarResponse removeCarResponse = check ep->RemoveCar(removeCarRequest);
    io:println("Remove Car Response: ", removeCarResponse);

    // 11. Add another car and remove it successfully
    io:println("\n11. Adding and removing another car...");
    Car secondCar = {
        plate: "REMOVE123", 
        make: "Honda", 
        model: "Civic", 
        year: 2022, 
        daily_price: 45.0, 
        mileage: 15000, 
        status: AVAILABLE, 
        description: "Car to be removed", 
        color: "Red", 
        fuel_type: "Gasoline"
    };
    AddCarResponse secondCarResponse = check ep->AddCar(secondCar);
    io:println("Second car added: ", secondCarResponse);
    
    RemoveCarRequest removeSecondCarRequest = {
        plate: "REMOVE123", 
        admin_id: "admin1"
    };
    RemoveCarResponse removeSecondCarResponse = check ep->RemoveCar(removeSecondCarRequest);
    io:println("Second car removed: ", removeSecondCarResponse);

    io:println("\n=== ALL TESTS COMPLETED ===");
}

// ===== TYPE DEFINITIONS =====

// Enum definitions
public enum carStatus {
    AVAILABLE,
    UNAVAILABLE,
    RENTED,
    MAINTENANCE
}

public enum userRole {
    CUSTOMER,
    ADMIN
}

public enum reservationStatus {
    PENDING,
    CONFIRMED,
    CANCELLED,
    COMPLETED
}

// Core entity types
public type car record {
    string plate;
    string make;
    string model;
    int year;
    float daily_price;
    int mileage;
    CarStatus status;
    string description;
    string color;
    string fuel_type;
};

public type user record {
    string user_id;
    string name;
    string email;
    string phone;
    UserRole role;
    string address;
    string license_number;
    int age;
};

public type cartItem record {
    string plate;
    string start_date;
    string end_date;
    float calculated_price;
    int rental_days;
    string car_make;
    string car_model;
};

public type reservation record {
    string reservation_id;
    string customer_id;
    string plate;
    string start_date;
    string end_date;
    float total_price;
    ReservationStatus status;
    string created_at;
    int rental_days;
    string customer_name;
    string car_info;
};

// Request/Response types
public type addCarResponse record {
    boolean success;
    string message;
    string car_id;
};

public type createUsersResponse record {
    boolean success;
    string message;
    int users_created;
    map<string> user_ids;
};

public type updateCarRequest record {
    string plate;
    Car updated_car;
};

public type updateCarResponse record {
    boolean success;
    string message;
    Car updated_car;
};

public type removeCarRequest record {
    string plate;
    string admin_id;
};

public type removeCarResponse record {
    boolean success;
    string message;
    map<Car> remaining_cars;
    int total_cars;
};

public type listReservationsRequest record {
    string admin_id;
    string filter_status;
    string start_date;
    string end_date;
};

public type listAvailableCarsRequest record {
    string customer_id;
    string filter_text;
    int filter_year;
    float max_price;
    string fuel_type;
};

public type searchCarRequest record {
    string plate;
    string customer_id;
};

public type searchCarResponse record {
    boolean found;
    boolean available;
    Car car;
    string message;
    map<string> unavailable_dates;
};

public type addToCartRequest record {
    string customer_id;
    string plate;
    string start_date;
    string end_date;
};

public type addToCartResponse record {
    boolean success;
    string message;
    CartItem cart_item;
    int cart_size;
};

public type placeReservationRequest record {
    string customer_id;
    string payment_method;
    string special_requests;
};

public type placeReservationResponse record {
    boolean success;
    string message;
    map<Reservation> reservations;
    float total_amount;
    string confirmation_number;
};

public type getCartRequest record {
    string customer_id;
};

public type getCartResponse record {
    CartItem[] items;
    float total_estimated_price;
    int total_days;
    boolean has_conflicts;
};