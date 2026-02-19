namespace my.Entities;

using managed from '@sap/cds/common';

type Amount {
  value : Decimal(6, 2);
  Curr  : String;
}

type Email   : String;

entity EmpTable {
  key ID         : UUID;
      Name       : String not null;
      Contact    : Integer;
      Address    : String;
      Salary     : Decimal(6, 2);
      // Salary: Amount;
      Email      : array of Email;
      Joindate   : Date;
      Jointime   : Time;
      extra      : Amount;
      Company_ID : Integer; //foreign key
      // company : Association to Company;                                    // Managed Association
      company    : Association to Company
                     on company.ID = $self.Company_ID; // Employe -> Company  ( UnManagged Association )

}

entity Company {
  key ID          : Integer;
      Name        : String;
      Location    : String;
      EmpTable_ID : String;
      // employee: Association to EmpTable;                                      // Managed Association
      employee    : Association to EmpTable
                      on employee.ID = $self.EmpTable_ID; // Company -> Employee ( UnManagged Association )
}

type Subject : String enum {
  PCM;
  BIO;
  COMMERECE;
  ARTS;
}

type Gender  : String enum {
  Male;
  Female;
  Other;
}

type Marks {
  English : Integer;
  Hindi   : Integer;
  Science : Integer;
  Maths   : Integer;
}

entity Student {
  key ID            : UUID;

      @mandatory
      Name          : String not null;
      Contact       : Integer;
      Email         : array of Email;
      dob           : Date;
      Address       : String  @assert      : (case
                                                when Address         is null
                                                     then 'Address is not null'
                                                when Address         =  ''
                                                     then 'Address not be empty'
                                                when length(Address) <  3
                                                     then 'Address is too short'
                                              end);
      Pincode       : Integer;
      Whole_Address : String = Address || '-' || Pincode;
      age           : Integer @assert.range: [
        3,
        20
      ];
      Subject       : Subject;
      Gender        : Gender;
      Marks         : Marks;
      Percentage    : Decimal(4, 2);
      isActive      : Boolean;
}


type Brand   : String enum {
  Adidas;
  Puma;
  Campus;
  RedTape;
}

type Status  : String enum {
  InStock;
  OutOfStock;
}

entity Product {
  key ProductID : UUID;
      ProdName  : String not null;
      Brand     : Brand;
      Category  : String default 'Shoes';
      price     : Amount;
      Quantity  : Integer @assert.range: [
        1,
        100
      ];
      MFD       : Date;
      Expiry    : Date;
      Status    : Status;

}

//----------Association---------
//Association is a relationship between two entities where they are connected but can exist independently.

entity OrderHeader {
  key ID        : UUID;
      OrderNo   : String;
      OrderDate : Date;

      // items : Association to OrderItem;                                  // managed Association
      items : Association to one OrderItem;                              // one to one Association
      // items : Association to many OrderItem                              // one to many Association
      //         on items.order = $self; // one to many association
      // items     : Association to many OrderLink // many to many Association
      //               on items.header = $self;
}

entity OrderItem {
  key ID      : UUID;
      Product : String;
      stock   : Integer;
      // order : Association to OrderHeader;                                   // managed Association
      order   : Association to one OrderHeader;
      // items   : Association to many OrderLink // many to many Association
      //             on items.item = $self;
}

entity OrderLink {
  key ID     : UUID;

      header : Association to one OrderHeader;
      item   : Association to one OrderItem;
}

//----------Composition----------
//Composition is a strong relationship where the child entity fully depends on the parent entity.
//Supported Deep Insert.

entity Human {
  key ID    : UUID;
      Name  : String;
      Age   : Integer;

      aadhar : Composition of one AadharCard on aadhar.parent = $self;       // One to One Compostion
      // aadhar : Composition of many AadharCard on aadhar.parent = $self;      // One to many Composition
      // links : Composition of many HumanAadhar
      //           on links.human = $self; // many to many Composition
}

entity AadharCard {
  key ID           : UUID;
      AadharNumber : Integer;
      Address      : String;

      parent : Association to Human;
      // links        : Composition of many HumanAadhar
      //                  on links.aadhar = $self; // many to many Composition
}

entity HumanAadhar {
  key ID     : UUID;

      human  : Association to Human;
      aadhar : Association to AadharCard;
}

//------------Context-------------
// context is a container or folder that groups multiple entities together.
// Performing Joins

context Sales {

  entity Customer {
    key ID   : UUID;
        name : String;
        city : String;
  }

  entity Order {
    key ID       : UUID;
        orderNo  : String;
        amount   : Decimal(10, 2);

        customer : Association to Customer;
  }

}
// Name ->  namespace_context_innercontext_entity
// my.Entities_Sales_Customer / Order

//---------------Aspects--------------
// aspect is a reusable structure that adds common fields to multiple entities.

aspect Name {
  first_name  : String;
  middle_name : String;
  Last_name   : String;
}

aspect Address {
  House_No    : Integer;
  Street_name : String;
  City        : String;
  state       : String;
  Pincode     : Integer;
}
// managed -> sap built in aspect

// a type of composite key
@assert.unique: {test: [
  Contact,
  Email
]}

entity Person : Name, Address, managed {
  key ID      : Integer;
      Contact : Integer not null;
      Email   : String not null;
      Age     : Integer @assert.range: [
        1,
        50
      ]
}

entity PersonLogs {
  key log     : String;
}

//---------------Keys-------------
// 1. Primary Key -> Uniquely identifies each record in a table.
// 2. Foreign Key -> A key that refers to the primary key of another table.   // Managed / Unmanaged Association
// 3. Unique      -> A field that not cantain duplicate values  (Composite Key)
// 4. Not Null    -> Fields cannot be passing null or blank
// 5. Check       -> CHECK keyword is a database constraint used to restrict values in a column.

//---------------Query-------------
// 1. Select -> Select Records from DB table. (.orderby , .having , .where , .from , .search , .columns)
// 2. Insert -> Insert Data to the DB.
// 3. Update -> Update the values in DB.
// 4. Delete -> Delete Records from DB.

//--------------Joins--------------
// 1. Left Join  -> All from Left + matches from Right.
// 2. Right Join -> All from Right + matches from Left.
// 3. Inner Join -> Only matching rows.
// 4. Full Outer Join -> All Records.
