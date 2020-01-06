public class HotelsSystemController {
	public String Name {get;set;}
    public String Email {get;set;}
    public String City {get;set;}
    public String Hotel {get;set;}
    public String NumberOfGuests {get;set;}
    public String cityId {get;set;}
    public String hotelId {get;set;}
    public Boolean Internet {get;set;}
    public Boolean Sauna {get;set;}
    public Boolean Beer {get;set;}
    public Integer initialLengthReservationsList {get;set;}
    public Integer finalLengthReservationsList {get;set;}
    public DateTime CheckInDate {get;set;}
    public DateTime CheckOutDate {get;set;}
    public List<Hotel__c> cityList {get;set;}
    public List<Hotel__c> hotelList {get;set;}
    public List<Room__c> roomList {get;set;}
    public List<Reservation__c> reservationsList {get;set;}
    public List<SelectOption> citySelectOptionList {get;set;}
    public List<SelectOption> hotelSelectOptionList {get;set;}  
    public List<SelectOption> guestsSelectOptionList {get;set;} 
    
    public HotelsSystemController() {
        
        cityList = [SELECT Id, City__c FROM Hotel__c ORDER BY Name ASC];
        
        cityId = !cityList.isEmpty() ? cityList[0].Id : NULL;
        
        hotelList = [SELECT Id, Name FROM Hotel__c WHERE id =: cityId ORDER BY Name ASC];
        
        hotelId = !hotelList.isEmpty() ? hotelList[0].Id : NULL;
        
        citySelectOptionList = new List<SelectOption>();
        hotelSelectOptionList = new List<SelectOption>();
        guestsSelectOptionList = new List<SelectOption>();
        
        guestsSelectOptionList.add(new SelectOption('1', '1'));
        guestsSelectOptionList.add(new SelectOption('2', '2'));
        guestsSelectOptionList.add(new SelectOption('3', '3'));
        guestsSelectOptionList.add(new SelectOption('4', '4'));
        guestsSelectOptionList.add(new SelectOption('5', '5'));
        guestsSelectOptionList.add(new SelectOption('6', '6'));
        guestsSelectOptionList.add(new SelectOption('7', '7'));
        guestsSelectOptionList.add(new SelectOption('8', '8'));
        guestsSelectOptionList.add(new SelectOption('9', '9'));
        guestsSelectOptionList.add(new SelectOption('10', '10'));
        
        for (Hotel__c item : cityList) {
            citySelectOptionList.add(new SelectOption(item.Id, item.City__c));
        }
        
        for (Hotel__c item : hotelList) {
            hotelSelectOptionList.add(new SelectOption(item.Id, item.Name));
        }
    } 
    
    public void refreshHotelList() {
        
         hotelList = [SELECT Id, Name FROM Hotel__c WHERE id =: cityId ORDER BY Name ASC];
         hotelSelectOptionList = new List<SelectOption>();
        
         for (Hotel__c item : hotelList) {
            hotelSelectOptionList.add(new SelectOption(item.Id, item.Name));
        }
    } 
    
    public void addData() { 
        
        if ( Name == '' || Email == '' ||  CheckInDate == Null || CheckOutDate == Null) {
            
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'Please fill in all fields!' ));
            
        } else { 
            
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(Email); 
    
        if (!MyMatcher.matches()) {
            
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'Email is incorrect!' ));
            
        } else {
            
        if (CheckInDate > CheckOutDate || CheckInDate < DateTime.now() || CheckOutDate < DateTime.now()) {
            
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'Enter the correct Check-In Date and Check-Out Date!' ));
            
		} else {
                  
            roomList = [SELECT id, Name FROM Room__c WHERE Hotel__r.Id = :hotelId AND Max_count_of_guests__c =: NumberOfGuests];
            reservationsList = [SELECT Check_In_Date__c, Check_Out_Date__c, Room__c FROM Reservation__c];
            initialLengthReservationsList = reservationsList.size();
            
            for (Room__c room : roomList) {
                
                Boolean isFREE = FALSE;
                
                for (Reservation__c reservation : reservationsList) {
                    
                     Boolean isIntersecting = reservation.Check_In_Date__c >= CheckInDate && reservation.Check_In_Date__c < CheckOutDate;
                    
                     isIntersecting |= CheckInDate >= reservation.Check_In_Date__c && CheckInDate < reservation.Check_Out_Date__c;
                        
                     if(room.Id == reservation.Room__c && isIntersecting) {
                        isFREE = FALSE;
                        break;
                     }
                    
                    else {
                    	isFREE = TRUE;
                    }
                }
                        
               if (isFREE) {
                   
                    try {
                        
                    Customer__c customer = new Customer__c(Name=Name, Email__c=Email);                        
                    insert customer;
                    ID customerID = customer.ID;
                        
                    Additional_services__c additionalServices = new Additional_services__c(Beer__c=Beer, Sauna__c=Sauna, Internet__c=Internet);                        
                    insert additionalServices; 
                    ID additionalServicesID = additionalServices.ID;
                    
                    Reservation__c reservationA = new Reservation__c(Check_In_Date__c=CheckInDate, 
                                                                    Check_Out_Date__c=CheckOutDate, 
                                                                    Customer__c=customerID,
                                                                    Additional_services__c=additionalServicesID,
                                                                    RecordTypeId=Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Pre-reservation').getRecordTypeId(),
                                                                    Room__c = room.Id,
                                                                    Number_of_guests__c = NumberOfGuests);    
                    insert reservationA;  
                        
                    } catch (Exception ex) {
                         ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()); 
                         ApexPages.addMessage(msg);
                    }
                   
                    try {
                         
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses = new String[] { Email };
                    message.optOutPolicy = 'FILTER';
                    message.subject = 'Booking Confirmation';
                    message.plainTextBody = 'Hello, '+ Name +'! You have reserved a room successfully! Number Of Guests: ' + NumberOfGuests + 
                        ', Check In Date: ' + CheckInDate + ', CheckOutDate: ' + CheckOutDate;
                    Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    
                    if (results[0].success) {
                        apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'A letter with details has been sent to your email!'));
                    } else {
                        apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'The email failed to send' + results[0].errors[0].message));
                    }     
                        
                    } catch (Exception ex) {
                         ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()); 
                         ApexPages.addMessage(msg);
                    }
                   
                    break;
               }
            }             
                
            reservationsList = [SELECT Check_In_Date__c, Check_Out_Date__c, Room__c FROM Reservation__c];
            finalLengthReservationsList = reservationsList.size();
                
            if (finalLengthReservationsList == initialLengthReservationsList) {
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Sorry, no rooms available at this time.'));
            } else {
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Room reserved successfully! Thank you for using our service!'));
            }
        }
        }
        }
    }
}