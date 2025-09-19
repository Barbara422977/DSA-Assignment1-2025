import ballerina/grpc;
import ballerina/protobuf;

public const string CARRENTAL_DESC = "0A0F63617252656E74616C2E70726F746F120A6361725F72656E74616C2298020A0343617212140A05706C6174651801200128095205706C61746512120A046D616B6518022001280952046D616B6512140A056D6F64656C18032001280952056D6F64656C12120A0479656172180420012805520479656172121F0A0B6461696C795F7072696365180520012801520A6461696C79507269636512180A076D696C6561676518062001280552076D696C65616765122D0A0673746174757318072001280E32152E6361725F72656E74616C2E436172537461747573520673746174757312200A0B6465736372697074696F6E180820012809520B6465736372697074696F6E12140A05636F6C6F721809200128095205636F6C6F72121B0A096675656C5F74797065180A2001280952086675656C5479706522DC010A045573657212170A07757365725F6964180120012809520675736572496412120A046E616D6518022001280952046E616D6512140A05656D61696C1803200128095205656D61696C12140A0570686F6E65180420012809520570686F6E6512280A04726F6C6518052001280E32142E6361725F72656E74616C2E55736572526F6C655204726F6C6512180A076164647265737318062001280952076164647265737312250A0E6C6963656E73655F6E756D626572180720012809520D6C6963656E73654E756D62657212100A03616765180820012805520361676522DE010A08436172744974656D12140A05706C6174651801200128095205706C617465121D0A0A73746172745F64617465180220012809520973746172744461746512190A08656E645F646174651803200128095207656E644461746512290A1063616C63756C617465645F7072696365180420012801520F63616C63756C617465645072696365121F0A0B72656E74616C5F64617973180520012805520A72656E74616C4461797312190A086361725F6D616B6518062001280952076361724D616B65121B0A096361725F6D6F64656C18072001280952086361724D6F64656C22FD020A0B5265736572766174696F6E12250A0E7265736572766174696F6E5F6964180120012809520D7265736572766174696F6E4964121F0A0B637573746F6D65725F6964180220012809520A637573746F6D6572496412140A05706C6174651803200128095205706C617465121D0A0A73746172745F64617465180420012809520973746172744461746512190A08656E645F646174651805200128095207656E6444617465121F0A0B746F74616C5F7072696365180620012801520A746F74616C507269636512350A0673746174757318072001280E321D2E6361725F72656E74616C2E5265736572766174696F6E5374617475735206737461747573121D0A0A637265617465645F61741808200128095209637265617465644174121F0A0B72656E74616C5F64617973180920012805520A72656E74616C4461797312230A0D637573746F6D65725F6E616D65180A20012809520C637573746F6D65724E616D6512190A086361725F696E666F180B200128095207636172496E666F225B0A0E416464436172526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D65737361676512150A066361725F6964180320012809520563617249642289010A134372656174655573657273526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D65737361676512230A0D75736572735F63726561746564180320012805520C75736572734372656174656412190A08757365725F696473180420032809520775736572496473225A0A105570646174654361725265717565737412140A05706C6174651801200128095205706C61746512300A0B757064617465645F63617218022001280B320F2E6361725F72656E74616C2E436172520A7570646174656443617222790A11557064617465436172526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D65737361676512300A0B757064617465645F63617218032001280B320F2E6361725F72656E74616C2E436172520A7570646174656443617222430A1052656D6F76654361725265717565737412140A05706C6174651801200128095205706C61746512190A0861646D696E5F6964180220012809520761646D696E4964229E010A1152656D6F7665436172526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D65737361676512360A0E72656D61696E696E675F6361727318032003280B320F2E6361725F72656E74616C2E436172520D72656D61696E696E6743617273121D0A0A746F74616C5F636172731804200128055209746F74616C436172732293010A174C6973745265736572766174696F6E735265717565737412190A0861646D696E5F6964180120012809520761646D696E496412230A0D66696C7465725F737461747573180220012809520C66696C746572537461747573121D0A0A73746172745F64617465180320012809520973746172744461746512190A08656E645F646174651804200128095207656E644461746522B7010A184C697374417661696C61626C654361727352657175657374121F0A0B637573746F6D65725F6964180120012809520A637573746F6D65724964121F0A0B66696C7465725F74657874180220012809520A66696C74657254657874121F0A0B66696C7465725F79656172180320012805520A66696C74657259656172121B0A096D61785F707269636518042001280152086D61785072696365121B0A096675656C5F7479706518052001280952086675656C5479706522490A105365617263684361725265717565737412140A05706C6174651801200128095205706C617465121F0A0B637573746F6D65725F6964180220012809520A637573746F6D6572496422B1010A11536561726368436172526573706F6E736512140A05666F756E641801200128085205666F756E64121C0A09617661696C61626C651802200128085209617661696C61626C6512210A0363617218032001280B320F2E6361725F72656E74616C2E436172520363617212180A076D65737361676518042001280952076D657373616765122B0A11756E617661696C61626C655F64617465731805200328095210756E617661696C61626C6544617465732283010A10416464546F4361727452657175657374121F0A0B637573746F6D65725F6964180120012809520A637573746F6D6572496412140A05706C6174651802200128095205706C617465121D0A0A73746172745F64617465180320012809520973746172744461746512190A08656E645F646174651804200128095207656E64446174652297010A11416464546F43617274526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D65737361676512310A09636172745F6974656D18032001280B32142E6361725F72656E74616C2E436172744974656D5208636172744974656D121B0A09636172745F73697A6518042001280552086361727453697A65228C010A17506C6163655265736572766174696F6E52657175657374121F0A0B637573746F6D65725F6964180120012809520A637573746F6D6572496412250A0E7061796D656E745F6D6574686F64180220012809520D7061796D656E744D6574686F6412290A107370656369616C5F7265717565737473180320012809520F7370656369616C526571756573747322DF010A18506C6163655265736572766174696F6E526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D657373616765123B0A0C7265736572766174696F6E7318032003280B32172E6361725F72656E74616C2E5265736572766174696F6E520C7265736572766174696F6E7312210A0C746F74616C5F616D6F756E74180420012801520B746F74616C416D6F756E74122F0A13636F6E6669726D6174696F6E5F6E756D6265721805200128095212636F6E6669726D6174696F6E4E756D62657222310A0E4765744361727452657175657374121F0A0B637573746F6D65725F6964180120012809520A637573746F6D6572496422B5010A0F47657443617274526573706F6E7365122A0A056974656D7318012003280B32142E6361725F72656E74616C2E436172744974656D52056974656D7312320A15746F74616C5F657374696D617465645F70726963651802200128015213746F74616C457374696D617465645072696365121D0A0A746F74616C5F646179731803200128055209746F74616C4461797312230A0D6861735F636F6E666C69637473180420012808520C686173436F6E666C696374732A480A09436172537461747573120D0A09415641494C41424C451000120F0A0B554E415641494C41424C451001120A0A0652454E5445441002120F0A0B4D41494E54454E414E434510032A230A0855736572526F6C65120C0A08435553544F4D4552100012090A0541444D494E10012A4D0A115265736572766174696F6E537461747573120B0A0750454E44494E471000120D0A09434F4E4649524D45441001120D0A0943414E43454C4C45441002120D0A09434F4D504C45544544100332FD050A1043617252656E74616C5365727669636512350A06416464436172120F2E6361725F72656E74616C2E4361721A1A2E6361725F72656E74616C2E416464436172526573706F6E736512420A0B437265617465557365727312102E6361725F72656E74616C2E557365721A1F2E6361725F72656E74616C2E4372656174655573657273526573706F6E7365280112480A09557064617465436172121C2E6361725F72656E74616C2E557064617465436172526571756573741A1D2E6361725F72656E74616C2E557064617465436172526573706F6E736512480A0952656D6F7665436172121C2E6361725F72656E74616C2E52656D6F7665436172526571756573741A1D2E6361725F72656E74616C2E52656D6F7665436172526573706F6E736512550A134C697374416C6C5265736572766174696F6E7312232E6361725F72656E74616C2E4C6973745265736572766174696F6E73526571756573741A172E6361725F72656E74616C2E5265736572766174696F6E3001124C0A114C697374417661696C61626C654361727312242E6361725F72656E74616C2E4C697374417661696C61626C6543617273526571756573741A0F2E6361725F72656E74616C2E436172300112480A09536561726368436172121C2E6361725F72656E74616C2E536561726368436172526571756573741A1D2E6361725F72656E74616C2E536561726368436172526573706F6E736512480A09416464546F43617274121C2E6361725F72656E74616C2E416464546F43617274526571756573741A1D2E6361725F72656E74616C2E416464546F43617274526573706F6E7365125D0A10506C6163655265736572766174696F6E12232E6361725F72656E74616C2E506C6163655265736572766174696F6E526571756573741A242E6361725F72656E74616C2E506C6163655265736572766174696F6E526573706F6E736512420A0747657443617274121A2E6361725F72656E74616C2E47657443617274526571756573741A1B2E6361725F72656E74616C2E47657443617274526573706F6E7365620670726F746F33";

public isolated client class CarRentalServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, CARRENTAL_DESC);
    }

    isolated remote function AddCar(Car|ContextCar req) returns AddCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        Car message;
        if req is ContextCar {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/AddCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <AddCarResponse>result;
    }

    isolated remote function AddCarContext(Car|ContextCar req) returns ContextAddCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        Car message;
        if req is ContextCar {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/AddCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <AddCarResponse>result, headers: respHeaders};
    }

    isolated remote function UpdateCar(UpdateCarRequest|ContextUpdateCarRequest req) returns UpdateCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdateCarRequest message;
        if req is ContextUpdateCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/UpdateCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <UpdateCarResponse>result;
    }

    isolated remote function UpdateCarContext(UpdateCarRequest|ContextUpdateCarRequest req) returns ContextUpdateCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdateCarRequest message;
        if req is ContextUpdateCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/UpdateCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <UpdateCarResponse>result, headers: respHeaders};
    }

    isolated remote function RemoveCar(RemoveCarRequest|ContextRemoveCarRequest req) returns RemoveCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemoveCarRequest message;
        if req is ContextRemoveCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/RemoveCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <RemoveCarResponse>result;
    }

    isolated remote function RemoveCarContext(RemoveCarRequest|ContextRemoveCarRequest req) returns ContextRemoveCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemoveCarRequest message;
        if req is ContextRemoveCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/RemoveCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <RemoveCarResponse>result, headers: respHeaders};
    }

    isolated remote function SearchCar(SearchCarRequest|ContextSearchCarRequest req) returns SearchCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchCarRequest message;
        if req is ContextSearchCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/SearchCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <SearchCarResponse>result;
    }

    isolated remote function SearchCarContext(SearchCarRequest|ContextSearchCarRequest req) returns ContextSearchCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchCarRequest message;
        if req is ContextSearchCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/SearchCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <SearchCarResponse>result, headers: respHeaders};
    }

    isolated remote function AddToCart(AddToCartRequest|ContextAddToCartRequest req) returns AddToCartResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddToCartRequest message;
        if req is ContextAddToCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/AddToCart", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <AddToCartResponse>result;
    }

    isolated remote function AddToCartContext(AddToCartRequest|ContextAddToCartRequest req) returns ContextAddToCartResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddToCartRequest message;
        if req is ContextAddToCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/AddToCart", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <AddToCartResponse>result, headers: respHeaders};
    }

    isolated remote function PlaceReservation(PlaceReservationRequest|ContextPlaceReservationRequest req) returns PlaceReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        PlaceReservationRequest message;
        if req is ContextPlaceReservationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/PlaceReservation", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <PlaceReservationResponse>result;
    }

    isolated remote function PlaceReservationContext(PlaceReservationRequest|ContextPlaceReservationRequest req) returns ContextPlaceReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        PlaceReservationRequest message;
        if req is ContextPlaceReservationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/PlaceReservation", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <PlaceReservationResponse>result, headers: respHeaders};
    }

    isolated remote function GetCart(GetCartRequest|ContextGetCartRequest req) returns GetCartResponse|grpc:Error {
        map<string|string[]> headers = {};
        GetCartRequest message;
        if req is ContextGetCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/GetCart", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <GetCartResponse>result;
    }

    isolated remote function GetCartContext(GetCartRequest|ContextGetCartRequest req) returns ContextGetCartResponse|grpc:Error {
        map<string|string[]> headers = {};
        GetCartRequest message;
        if req is ContextGetCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/GetCart", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <GetCartResponse>result, headers: respHeaders};
    }

    isolated remote function CreateUsers() returns CreateUsersStreamingClient|grpc:Error {
        grpc:StreamingClient sClient = check self.grpcClient->executeClientStreaming("car_rental.CarRentalService/CreateUsers");
        return new CreateUsersStreamingClient(sClient);
    }

    isolated remote function ListAllReservations(ListReservationsRequest|ContextListReservationsRequest req) returns stream<Reservation, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        ListReservationsRequest message;
        if req is ContextListReservationsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("car_rental.CarRentalService/ListAllReservations", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        ReservationStream outputStream = new ReservationStream(result);
        return new stream<Reservation, grpc:Error?>(outputStream);
    }

    isolated remote function ListAllReservationsContext(ListReservationsRequest|ContextListReservationsRequest req) returns ContextReservationStream|grpc:Error {
        map<string|string[]> headers = {};
        ListReservationsRequest message;
        if req is ContextListReservationsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("car_rental.CarRentalService/ListAllReservations", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        ReservationStream outputStream = new ReservationStream(result);
        return {content: new stream<Reservation, grpc:Error?>(outputStream), headers: respHeaders};
    }

    isolated remote function ListAvailableCars(ListAvailableCarsRequest|ContextListAvailableCarsRequest req) returns stream<Car, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailableCarsRequest message;
        if req is ContextListAvailableCarsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("car_rental.CarRentalService/ListAvailableCars", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        CarStream outputStream = new CarStream(result);
        return new stream<Car, grpc:Error?>(outputStream);
    }

    isolated remote function ListAvailableCarsContext(ListAvailableCarsRequest|ContextListAvailableCarsRequest req) returns ContextCarStream|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailableCarsRequest message;
        if req is ContextListAvailableCarsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("car_rental.CarRentalService/ListAvailableCars", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        CarStream outputStream = new CarStream(result);
        return {content: new stream<Car, grpc:Error?>(outputStream), headers: respHeaders};
    }
}

public isolated client class CreateUsersStreamingClient {
    private final grpc:StreamingClient sClient;

    isolated function init(grpc:StreamingClient sClient) {
        self.sClient = sClient;
    }

    isolated remote function sendUser(User message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function sendContextUser(ContextUser message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function receiveCreateUsersResponse() returns CreateUsersResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, _] = response;
            return <CreateUsersResponse>payload;
        }
    }

    isolated remote function receiveContextCreateUsersResponse() returns ContextCreateUsersResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, headers] = response;
            return {content: <CreateUsersResponse>payload, headers: headers};
        }
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.sClient->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.sClient->complete();
    }
}

public class ReservationStream {
    private stream<anydata, grpc:Error?> anydataStream;

    public isolated function init(stream<anydata, grpc:Error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|Reservation value;|}|grpc:Error? {
        var streamValue = self.anydataStream.next();
        if streamValue is () {
            return streamValue;
        } else if streamValue is grpc:Error {
            return streamValue;
        } else {
            record {|Reservation value;|} nextRecord = {value: <Reservation>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns grpc:Error? {
        return self.anydataStream.close();
    }
}

public class CarStream {
    private stream<anydata, grpc:Error?> anydataStream;

    public isolated function init(stream<anydata, grpc:Error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|Car value;|}|grpc:Error? {
        var streamValue = self.anydataStream.next();
        if streamValue is () {
            return streamValue;
        } else if streamValue is grpc:Error {
            return streamValue;
        } else {
            record {|Car value;|} nextRecord = {value: <Car>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns grpc:Error? {
        return self.anydataStream.close();
    }
}

public type ContextUserStream record {|
    stream<User, error?> content;
    map<string|string[]> headers;
|};

public type ContextReservationStream record {|
    stream<Reservation, error?> content;
    map<string|string[]> headers;
|};

public type ContextCarStream record {|
    stream<Car, error?> content;
    map<string|string[]> headers;
|};

public type ContextListReservationsRequest record {|
    ListReservationsRequest content;
    map<string|string[]> headers;
|};

public type ContextUser record {|
    User content;
    map<string|string[]> headers;
|};

public type ContextPlaceReservationResponse record {|
    PlaceReservationResponse content;
    map<string|string[]> headers;
|};

public type ContextRemoveCarRequest record {|
    RemoveCarRequest content;
    map<string|string[]> headers;
|};

public type ContextUpdateCarRequest record {|
    UpdateCarRequest content;
    map<string|string[]> headers;
|};

public type ContextAddCarResponse record {|
    AddCarResponse content;
    map<string|string[]> headers;
|};

public type ContextAddToCartResponse record {|
    AddToCartResponse content;
    map<string|string[]> headers;
|};

public type ContextUpdateCarResponse record {|
    UpdateCarResponse content;
    map<string|string[]> headers;
|};

public type ContextAddToCartRequest record {|
    AddToCartRequest content;
    map<string|string[]> headers;
|};

public type ContextListAvailableCarsRequest record {|
    ListAvailableCarsRequest content;
    map<string|string[]> headers;
|};

public type ContextSearchCarRequest record {|
    SearchCarRequest content;
    map<string|string[]> headers;
|};

public type ContextRemoveCarResponse record {|
    RemoveCarResponse content;
    map<string|string[]> headers;
|};

public type ContextReservation record {|
    Reservation content;
    map<string|string[]> headers;
|};

public type ContextGetCartRequest record {|
    GetCartRequest content;
    map<string|string[]> headers;
|};

public type ContextCar record {|
    Car content;
    map<string|string[]> headers;
|};

public type ContextPlaceReservationRequest record {|
    PlaceReservationRequest content;
    map<string|string[]> headers;
|};

public type ContextSearchCarResponse record {|
    SearchCarResponse content;
    map<string|string[]> headers;
|};

public type ContextCreateUsersResponse record {|
    CreateUsersResponse content;
    map<string|string[]> headers;
|};

public type ContextGetCartResponse record {|
    GetCartResponse content;
    map<string|string[]> headers;
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type ListReservationsRequest record {|
    string admin_id = "";
    string filter_status = "";
    string start_date = "";
    string end_date = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type User record {|
    string user_id = "";
    string name = "";
    string email = "";
    string phone = "";
    UserRole role = CUSTOMER;
    string address = "";
    string license_number = "";
    int age = 0;
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type PlaceReservationResponse record {|
    boolean success = false;
    string message = "";
    Reservation[] reservations = [];
    float total_amount = 0.0;
    string confirmation_number = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type RemoveCarRequest record {|
    string plate = "";
    string admin_id = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type UpdateCarRequest record {|
    string plate = "";
    Car updated_car = {};
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type AddCarResponse record {|
    boolean success = false;
    string message = "";
    string car_id = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type AddToCartResponse record {|
    boolean success = false;
    string message = "";
    CartItem cart_item = {};
    int cart_size = 0;
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type UpdateCarResponse record {|
    boolean success = false;
    string message = "";
    Car updated_car = {};
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type CartItem record {|
    string plate = "";
    string start_date = "";
    string end_date = "";
    float calculated_price = 0.0;
    int rental_days = 0;
    string car_make = "";
    string car_model = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type AddToCartRequest record {|
    string customer_id = "";
    string plate = "";
    string start_date = "";
    string end_date = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type ListAvailableCarsRequest record {|
    string customer_id = "";
    string filter_text = "";
    int filter_year = 0;
    float max_price = 0.0;
    string fuel_type = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type SearchCarRequest record {|
    string plate = "";
    string customer_id = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type RemoveCarResponse record {|
    boolean success = false;
    string message = "";
    Car[] remaining_cars = [];
    int total_cars = 0;
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type Reservation record {|
    string reservation_id = "";
    string customer_id = "";
    string plate = "";
    string start_date = "";
    string end_date = "";
    float total_price = 0.0;
    ReservationStatus status = PENDING;
    string created_at = "";
    int rental_days = 0;
    string customer_name = "";
    string car_info = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type GetCartRequest record {|
    string customer_id = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type Car record {|
    string plate = "";
    string make = "";
    string model = "";
    int year = 0;
    float daily_price = 0.0;
    int mileage = 0;
    CarStatus status = AVAILABLE;
    string description = "";
    string color = "";
    string fuel_type = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type PlaceReservationRequest record {|
    string customer_id = "";
    string payment_method = "";
    string special_requests = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type SearchCarResponse record {|
    boolean found = false;
    boolean available = false;
    Car car = {};
    string message = "";
    string[] unavailable_dates = [];
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type CreateUsersResponse record {|
    boolean success = false;
    string message = "";
    int users_created = 0;
    string[] user_ids = [];
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type GetCartResponse record {|
    CartItem[] items = [];
    float total_estimated_price = 0.0;
    int total_days = 0;
    boolean has_conflicts = false;
|};

public enum CarStatus {
    AVAILABLE, UNAVAILABLE, RENTED, MAINTENANCE
}

public enum UserRole {
    CUSTOMER, ADMIN
}

public enum ReservationStatus {
    PENDING, CONFIRMED, CANCELLED, COMPLETED
}
