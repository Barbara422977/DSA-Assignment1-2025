import ballerina/grpc;
import ballerina/log;
import ballerina/time;
import ballerina/uuid;

listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: CARRENTAL_DESC}
service "CarRentalService" on ep {

    // In-memory storage using maps
    private map<Car> cars = {};
    private map<User> users = {};
    private map<map<CartItem>> userCarts = {}; 
    private map<Reservation> reservations = {};

    // ===== ADMIN OPERATIONS =====

    remote function AddCar(Car value) returns AddCarResponse|error {
        log:printInfo("Admin adding car with plate: " + value.plate);
        
        // Validate required fields
        if value.plate.trim() == "" {
            return {
                success: false,
                message: "Car plate number is required",
                car_id: ""
            };
        }
        
        // Check if car already exists
        if self.cars.hasKey(value.plate) {
            return {
                success: false,
                message: "Car with plate " + value.plate + " already exists",
                car_id: ""
            };
        }

        // Validate car data
        if value.daily_price <= 0.0 {
            return {
                success: false,
                message: "Daily price must be greater than 0",
                car_id: ""
            };
        }

        // Add car to storage
        self.cars[value.plate] = value;
        
        log:printInfo("Car " + value.plate + " added successfully");
        return {
            success: true,
            message: "Car added successfully to the system",
            car_id: value.plate
        };
    }

    remote function UpdateCar(UpdateCarRequest value) returns UpdateCarResponse|error {
        log:printInfo("Admin updating car with plate: " + value.plate);
        
        if !self.cars.hasKey(value.plate) {
            return {
                success: false,
                message: "Car with plate " + value.plate + " not found",
                updated_car: {}
            };
        }

        // Validate updated car data
        if value.updated_car.daily_price <= 0.0 {
            return {
                success: false,
                message: "Daily price must be greater than 0",
                updated_car: {}
            };
        }

        // Update the car (preserve the original plate)
        Car updatedCar = value.updated_car;
        updatedCar.plate = value.plate;
        self.cars[value.plate] = updatedCar;
        
        log:printInfo("Car " + value.plate + " updated successfully");
        return {
            success: true,
            message: "Car details updated successfully",
            updated_car: updatedCar
        };
    }

    remote function RemoveCar(RemoveCarRequest value) returns RemoveCarResponse|error {
        log:printInfo("Admin removing car with plate: " + value.plate);
        
        // Verify admin authorization if admin_id is provided
        if value.admin_id != "" && self.users.hasKey(value.admin_id) {
            User admin = self.users.get(value.admin_id);
            if admin.role != ADMIN {
                return {
                    success: false,
                    message: "Unauthorized: Admin privileges required",
                    remaining_cars: [],
                    total_cars: 0
                };
            }
        }
        
        if !self.cars.hasKey(value.plate) {
            return {
                success: false,
                message: "Car with plate " + value.plate + " not found",
                remaining_cars: [],
                total_cars: 0
            };
        }

        // Check if car has active reservations
        foreach Reservation reservation in self.reservations {
            if reservation.plate == value.plate && reservation.status == CONFIRMED {
                return {
                    success: false,
                    message: "Cannot remove car with active reservations",
                    remaining_cars: [],
                    total_cars: 0
                };
            }
        }

        // Remove car
        _ = self.cars.remove(value.plate);
        
        log:printInfo("Car " + value.plate + " removed successfully");
        return {
            success: true,
            message: "Car removed successfully from the system",
            remaining_cars: self.cars.clone(),
            total_cars: self.cars.length()
        };
    }

    remote function CreateUsers(stream<User, grpc:Error?> clientStream) returns CreateUsersResponse|error {
        log:printInfo("Creating users via stream...");
        int userCount = 0;
        map<string> createdUserIds = {};
        
        record {|User value;|}|grpc:Error? next = clientStream.next();
        while next !is grpc:Error? {
            if next is record {|User value;|} {
                User user = next.value;
                
                // Validate user data
                if user.user_id.trim() == "" || user.name.trim() == "" {
                    log:printWarn("Skipping user with invalid data");
                    next = clientStream.next();
                    continue;
                }
                
                // Check if user already exists
                if !self.users.hasKey(user.user_id) {
                    self.users[user.user_id] = user;
                    self.userCarts[user.user_id] = {}; // Initialize empty cart
                    createdUserIds[userCount.toString()] = user.user_id;
                    userCount += 1;
                    log:printInfo("Created user: " + user.name + " with ID: " + user.user_id);
                } else {
                    log:printWarn("User " + user.user_id + " already exists, skipping");
                }
            }
            next = clientStream.next();
        }
        
        return {
            success: userCount > 0,
            message: "Successfully created " + userCount.toString() + " users",
            users_created: userCount,
            user_ids: createdUserIds
        };
    }

    remote function ListAllReservations(ListReservationsRequest value) returns stream<Reservation, error?>|error {
        log:printInfo("Admin listing all reservations");
        
        // Check admin authorization
        if !self.users.hasKey(value.admin_id) {
            return error("User not found");
        }
        
        User admin = self.users.get(value.admin_id);
        if admin.role != ADMIN {
            return error("Unauthorized: Admin access required");
        }

        map<Reservation> filteredReservations = {};
        int index = 0;
        
        foreach Reservation reservation in self.reservations {
            // Apply filters if provided
            boolean includeReservation = true;
            
            if value.filter_status != "" {
                includeReservation = includeReservation && 
                    (reservation.status.toString().toLowerAscii() == value.filter_status.toLowerAscii());
            }
            
            if includeReservation {
                filteredReservations[index.toString()] = reservation;
                index += 1;
            }
        }
        
        log:printInfo("Returning " + filteredReservations.length().toString() + " reservations");
        return filteredReservations.toArray().toStream();
    }

    // ===== CUSTOMER OPERATIONS =====

    remote function SearchCar(SearchCarRequest value) returns SearchCarResponse|error {
        log:printInfo("Customer " + value.customer_id + " searching for car: " + value.plate);
        
        // Verify customer exists
        if !self.users.hasKey(value.customer_id) {
            return {
                found: false,
                available: false,
                car: {},
                message: "Customer not found",
                unavailable_dates: []
            };
        }
        
        if !self.cars.hasKey(value.plate) {
            return {
                found: false,
                available: false,
                car: {},
                message: "Car not found in system",
                unavailable_dates: []
            };
        }

        Car car = self.cars.get(value.plate);
        boolean isAvailable = car.status == AVAILABLE;
        
        // Get unavailable dates for this car
        map<string> unavailableDates = {};
        if !isAvailable {
            int dateIndex = 0;
            foreach Reservation reservation in self.reservations {
                if reservation.plate == value.plate && reservation.status == CONFIRMED {
                    unavailableDates[dateIndex.toString()] = reservation.start_date + " to " + reservation.end_date;
                    dateIndex += 1;
                }
            }
        }
        
        return {
            found: true,
            available: isAvailable,
            car: car,
            message: isAvailable ? "Car is available for rent" : "Car is currently not available",
            unavailable_dates: unavailableDates
        };
    }

    remote function ListAvailableCars(ListAvailableCarsRequest value) returns stream<Car, error?>|error {
        log:printInfo("Customer " + value.customer_id + " listing available cars");
        
        // Verify customer exists
        if !self.users.hasKey(value.customer_id) {
            return error("Customer not found");
        }
        
        map<Car> availableCars = {};
        int carIndex = 0;
        
        foreach Car car in self.cars {
            if car.status == AVAILABLE {
                // Apply filters if provided
                boolean matches = true;
                
                // Text filter (make, model, description)
                if value.filter_text != "" {
                    string filterLower = value.filter_text.toLowerAscii();
                    string carInfo = (car.make + " " + car.model + " " + car.description + " " + car.color).toLowerAscii();
                    matches = matches && carInfo.includes(filterLower);
                }
                
                // Year filter
                if value.filter_year > 0 {
                    matches = matches && car.year == value.filter_year;
                }
                
                // Price filter
                if value.max_price > 0.0 {
                    matches = matches && car.daily_price <= value.max_price;
                }
                
                // Fuel type filter
                if value.fuel_type != "" {
                    matches = matches && car.fuel_type.toLowerAscii() == value.fuel_type.toLowerAscii();
                }
                
                if matches {
                    availableCars[carIndex.toString()] = car;
                    carIndex += 1;
                }
            }
        }
        
        log:printInfo("Returning " + availableCars.length().toString() + " available cars");
        return availableCars.toArray().toStream();
    }

    remote function AddToCart(AddToCartRequest value) returns AddToCartResponse|error {
        log:printInfo("Customer " + value.customer_id + " adding car " + value.plate + " to cart");
        
        // Verify customer exists
        if !self.users.hasKey(value.customer_id) {
            return {
                success: false,
                message: "Customer not found",
                cart_item: {},
                cart_size: 0
            };
        }
        
        // Validate car exists and is available
        if !self.cars.hasKey(value.plate) {
            return {
                success: false,
                message: "Car not found in system",
                cart_item: {},
                cart_size: 0
            };
        }

        Car car = self.cars.get(value.plate);
        if car.status != AVAILABLE {
            return {
                success: false,
                message: "Car is not available for rent",
                cart_item: {},
                cart_size: 0
            };
        }

        // Validate dates
        time:Utc|error startTime = time:utcFromString(value.start_date + "T00:00:00.000Z");
        time:Utc|error endTime = time:utcFromString(value.end_date + "T00:00:00.000Z");
        
        if startTime is error || endTime is error {
            return {
                success: false,
                message: "Invalid date format. Use YYYY-MM-DD format",
                cart_item: {},
                cart_size: 0
            };
        }

        if startTime >= endTime {
            return {
                success: false,
                message: "End date must be after start date",
                cart_item: {},
                cart_size: 0
            };
        }

        // Check if dates are in the future
        time:Utc currentTime = time:utcNow();
        if startTime <= currentTime {
            return {
                success: false,
                message: "Start date must be in the future",
                cart_item: {},
                cart_size: 0
            };
        }

        // Calculate days and price
        time:Seconds duration = time:utcDiffSeconds(endTime, startTime);
        int days = <int>(duration / (24 * 60 * 60));
        if days == 0 {
            days = 1; // Minimum 1 day rental
        }
        float totalPrice = days * car.daily_price;

        // Create cart item
        CartItem cartItem = {
            plate: value.plate,
            start_date: value.start_date,
            end_date: value.end_date,
            calculated_price: totalPrice,
            rental_days: days,
            car_make: car.make,
            car_model: car.model
        };

        // Initialize cart if doesn't exist
        if !self.userCarts.hasKey(value.customer_id) {
            self.userCarts[value.customer_id] = {};
        }
        
        map<CartItem> currentCart = self.userCarts.get(value.customer_id);
        
        // Check for duplicate entries
        foreach CartItem item in currentCart {
            if item.plate == value.plate {
                return {
                    success: false,
                    message: "Car is already in your cart",
                    cart_item: {},
                    cart_size: currentCart.length()
                };
            }
        }
        
        // Add new item to cart
        currentCart[currentCart.length().toString()] = cartItem;
        self.userCarts[value.customer_id] = currentCart;

        log:printInfo("Car " + value.plate + " added to cart for customer " + value.customer_id);
        return {
            success: true,
            message: "Car added to cart successfully",
            cart_item: cartItem,
            cart_size: currentCart.length()
        };
    }

    remote function GetCart(GetCartRequest value) returns GetCartResponse|error {
        log:printInfo("Getting cart for customer: " + value.customer_id);
        
        // Verify customer exists
        if !self.users.hasKey(value.customer_id) {
            return {
                items: [],
                total_estimated_price: 0.0,
                total_days: 0,
                has_conflicts: false
            };
        }
        
        if !self.userCarts.hasKey(value.customer_id) {
            return {
                items: [],
                total_estimated_price: 0.0,
                total_days: 0,
                has_conflicts: false
            };
        }

        map<CartItem> cartMap = self.userCarts.get(value.customer_id);
        CartItem[] cart = cartMap.toArray();
        
        float totalPrice = 0.0;
        int totalDays = 0;
        boolean hasConflicts = false;
        
        foreach CartItem item in cart {
            totalPrice += item.calculated_price;
            totalDays += item.rental_days;
            
            // Check if car is still available
            if self.cars.hasKey(item.plate) {
                Car car = self.cars.get(item.plate);
                if car.status != AVAILABLE {
                    hasConflicts = true;
                }
            } else {
                hasConflicts = true;
            }
        }
        
        return {
            items: cart,
            total_estimated_price: totalPrice,
            total_days: totalDays,
            has_conflicts: hasConflicts
        };
    }

    remote function PlaceReservation(PlaceReservationRequest value) returns PlaceReservationResponse|error {
        log:printInfo("Customer " + value.customer_id + " placing reservation");
        
        // Verify customer exists
        if !self.users.hasKey(value.customer_id) {
            return {
                success: false,
                message: "Customer not found",
                reservations: [],
                total_amount: 0.0,
                confirmation_number: ""
            };
        }
        
        if !self.userCarts.hasKey(value.customer_id) {
            return {
                success: false,
                message: "No items in cart",
                reservations: [],
                total_amount: 0.0,
                confirmation_number: ""
            };
        }

        map<CartItem> cartMap = self.userCarts.get(value.customer_id);
        CartItem[] cart = cartMap.toArray();
        
        if cart.length() == 0 {
            return {
            success: false,
            message: "Cart is empty",
            reservations: [],   
            total_amount: 0.0,
            confirmation_number: ""
};

        }

        // Verify all cars are still available
        foreach CartItem item in cart {
            if !self.cars.hasKey(item.plate) {
                return {
                    success: false,
                    message: "Car " + item.plate + " no longer exists in system",
                    reservations: [],
                    total_amount: 0.0,
                    confirmation_number: ""
                };
            }
            
            Car car = self.cars.get(item.plate);
            if car.status != AVAILABLE {
                return {
                    success: false,
                    message: "Car " + item.plate + " is no longer available",
                    reservations: [],
                    total_amount: 0.0,
                    confirmation_number: ""
                };
            }
        }

        // Create reservations
        map<Reservation> newReservations = {};
        float totalAmount = 0.0;
        time:Utc currentTime = time:utcNow();
        string confirmationNumber = "CR" + uuid:createType4AsString().substring(0, 8).toUpperAscii();
        User customer = self.users.get(value.customer_id);
        
        int reservationIndex = 0;
        foreach CartItem item in cart {
            string reservationId = uuid:createType4AsString();
            Car car = self.cars.get(item.plate);
            
            Reservation reservation = {
                reservation_id: reservationId,
                customer_id: value.customer_id,
                plate: item.plate,
                start_date: item.start_date,
                end_date: item.end_date,
                total_price: item.calculated_price,
                status: CONFIRMED,
                created_at: time:utcToString(currentTime),
                rental_days: item.rental_days,
                customer_name: customer.name,
                car_info: car.make + " " + car.model
            };
            
            self.reservations[reservationId] = reservation;
            newReservations[reservationIndex.toString()] = reservation;
            reservationIndex += 1;
            totalAmount += item.calculated_price;
            
            // Update car status to rented
            car.status = RENTED;
            self.cars[item.plate] = car;
        }

        // Clear the cart
        self.userCarts[value.customer_id] = {};

        log:printInfo("Reservations placed successfully for customer " + value.customer_id);
        return {
            success: true,
            message: "Reservations placed successfully! Confirmation: " + confirmationNumber,
            reservations: newReservations,
            total_amount: totalAmount,
            confirmation_number: confirmationNumber
        };
    }
}

// Protocol Buffer descriptor placeholder
const string cARRENTAL_DESC = "car_rental.proto";

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