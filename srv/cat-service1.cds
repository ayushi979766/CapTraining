using my.Entities as my from '../db/schema';

service MyService1 {

      ///////////////// Projections /////////////////////
      // Exposed Entities -> a database entity that is made accessible through a service definition (OData or REST APIs)
      // all are exposed entities.

      entity EmpTable    as projection on my.EmpTable;
      entity Student     as projection on my.Student;
      entity Product     as projection on my.Product;
      entity Company     as projection on my.Company;
      entity OrderHeader as projection on my.OrderHeader;
      entity OrderItem   as projection on my.OrderItem;
      entity OrderLink   as projection on my.OrderLink;
      entity Human       as projection on my.Human;
      entity AadharCard  as projection on my.AadharCard;
      entity HumanAadhar as projection on my.HumanAadhar;
      entity Person      as projection on my.Person;
      entity PersonLogs  as projection on my.PersonLogs;
      entity Customer    as projection on my.Sales.Customer;
      entity Order       as projection on my.Sales.Order;



      //////////////// Views ///////////////////////////


      // view OrderDetails as select from my.OrderHeader{
      //      ID,
      //      OrderNo
      // };

      // view OrderItemDetails as select from my.OrderHeader{
      //     OrderNo,
      //     OrderDate,
      //     items.ID,
      //     items.Product,
      //     count(ID) as NoofOrders : Integer,
      //     sum(items.stock) as AvgStock : Integer

      // }group by items.ID, items.Product;

      // view WithParams(Parameter: String) as select from my.OrderHeader{
      //       ID,
      //       OrderNo,
      //       OrderDate
      // }where OrderNo= :Parameter    // error


      ///////////////// Functions //////////////////////

      // Unbound Function

      function welcome()                                         returns String;
      function Addition(a: Integer, b: Integer)                  returns Integer;

      type Priceinfo {
            original : Integer;
            discount : Integer;
            final    : Integer;
      }

      function CalculatePrice(price: Integer, discount: Integer) returns Priceinfo;

      // Bound Function

      //  entity OrderItem as projection on my.OrderItem actions{
      //     function getStockStatus() returns String;
      //  };


      ///////////////// Actions ////////////////////////

      // Unbound Action

      action   getNotification(message: String)                  returns String;

// Bound Action

// entity Items as projection on my.OrderItem actions{
//     action getResult() returns Boolean;
// };

}
