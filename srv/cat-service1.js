const cds = require('@sap/cds');
const { many } = require('@sap/cds/lib/compile/resolve');
const { SELECT, UPDATE, INSERT, DELETE } = require('@sap/cds/lib/ql/cds-ql');

module.exports = cds.service.impl((srv) => {

    // before -> Runs before the database action (CRUD). (check Validation)

    srv.before('CREATE', 'EmpTable', async (req) => {
        console.log('Entered Validation');
    })

    // on -> Runs instead of default behavior. (custom Logic)

    srv.on('welcome', () => {
        return 'Welcome in CAPM session'
    })

    // after -> Runs after database operation. (change output) 

    srv.after('CREATE', 'OrderHeader', (data) => {

        if (!Array.isArray(data)) {
            console.log("Order Created");
        }
    })

    ////////////////////////////// function ///////////////////////////

    srv.on('Addition', req => {
        const { a, b } = req.data
        return a + b;

    })

    srv.on('CalculatePrice', req => {
        const { price, discount } = req.data
        return {
            original: price,
            discount: discount,
            final: price - discount
        }
    })

    srv.on('getStockStatus', 'OrderItem', async (req) => {
        const id = req.params[0].ID;

        const item = await SELECT.one.from('my.Entities.OrderItem')
            .where({ ID: id })
            .columns('stock');

        if (!item) return req.error(404, `item ${id} is not found`);
        return item.stock > 0 ? 'In Stock' : 'No Stock';
    })

    srv.on('getNotification', async (req) => {
        const { message } = req.data;
        console.log('system alert ${message}');
        return "Notification Sent Successfully";

    })

    srv.on('getResult', async (req) => {
        const id = req.params[0].ID || req.params[0];

        const updaterow = await UPDATE('my.Entities.OrderItem')
            .set({ stock: 0 })
            .where({ ID: id })

        return updaterow > 0;

    })


    /////////////////////////// Queries /////////////////////////////

    //  1. SELECT USING CLAUSES

    // Read operation
    srv.on('READ', 'Person', async (req) => {
        console.log('Person Data:');
        let allData = await SELECT.from('my.Entities.Person')
            .where('ID IS NOT NULL')
            .columns('first_name', 'ID', 'count(ID) as totalCount', 'Contact', 'Email', 'Age', 'City')
            .orderBy('Age asc')
            .groupBy('Age', 'City');

        return allData;
    });

    // Error Notification
    srv.after('READ', 'Person', async (data, req) => {
        if (!data || data.length === 0) {
            req.reject(500, 'No Data Found!');
        }
    });


    // 2. INSERT Query

    // Validation Logic
    srv.before('CREATE', 'Person', async (req) => {
        if (!req.data.ID) {
            return req.reject(400, 'Id field is Mandatory!');
        }
    });

    // Insert Operation Perform
    srv.on('CREATE', 'Person', async (req) => {
        let payloadPerson = req.data;
        let Person = await INSERT.into('my.Entities.Person').entries(payloadPerson);

        let payloadLog = {
            "log": `Person with Identity ${req.data.ID} Created Successfully!`
        }

        let PersonLog = await INSERT.into('my.Entities.PersonLogs').entries(payloadLog);

        return payloadPerson;
    });

    // Post-Success Notification
    srv.after('CREATE', 'Person', async (data, req) => {
        if (data > 0) {
            req.notify(201, 'Person Added Successfully!');
            return ('Record Added Successfully! And Log is Created');
        }
    });

    // 3. UPDATE Query

    // Validation Logic
    srv.before('UPDATE', 'Person', async (req) => {
        const id = req.params[0].ID || req.data.ID;
        let getData = await SELECT.one.from('my.Entities.Person').where({ ID: id });

        if (!getData) {
            return req.reject(400, `Person with ID ${id} not found`);
        }
    });

    // Update Operation
    srv.on('UPDATE', 'Person', async (req) => {
        const id = req.params[0].ID || req.data.ID;
        let ChangePayload = req.data;

        let PersonUpdate = await UPDATE('my.Entities.Person').set(ChangePayload).where({ ID: id });
        return PersonUpdate;

    });

    // Post-Success Notification
    srv.after('UPDATE', 'Person', async (data, req) => {
        if (data > 0) {
            req.notify(201, 'Record Updated Successfully!');
            return ('Record Updated Successfully!');
        }
    });

    // 4. DELETE Query

    // Validation Logic
    srv.before('DELETE', 'Person', async (req) => {
        const id = req.params[0].ID || req.data.ID;
        let getData = await SELECT.one.from('my.Entities.Person').where({ ID: id });

        if (!getData) {
            return req.reject(400, `Person with ID ${id} not found`);
        }
    });

    // Delete Operation
    srv.on('DELETE', 'Person', async (req) => {
        const id = req.params[0].ID || req.data.ID;

        let DeletePerson = await DELETE.from('my.Entities.Person').where({ ID: id });
        return DeletePerson

    });

    // Post-Success Notification
    srv.after('DELETE', 'Person', async (data, req) => {
        if (data > 0) {
            req.notify(200, 'Record Deleted Successfully!');
        }
    });


    //////////////////////////// Joins ////////////////////////////

    // 1. Inner join
    srv.on('READ', 'Customer', async (req) => {
        let innerJoindata = await SELECT.from('my.Entities.Sales.Customer as a')
            .join('my.Entities.Sales.Order as b')
            .on('a.ID = b.customer_ID')
            .columns(['a.ID', 'a.name', 'a.city', { 'b.ID': 'Order_id' },
                { 'b.orderNo': 'OrderNo' }, { 'b.amount': 'order_ammount' }]);
        // return innerJoindata;


        // 2. Left Join
        let LeftJoindata = await SELECT.from('my.Entities.Sales.Customer as a')
            .leftJoin('my.Entities.Sales.Order as b')
            .on('a.ID = b.customer_ID')
            .columns(['a.ID', 'a.name', 'a.city', { 'b.ID': 'Order_id' },
                { 'b.orderNo': 'OrderNo' }, { 'b.amount': 'order_ammount' }]);
        // return LeftJoindata;


        // 3. Right Join
        let RightJoinData = await SELECT.from('my.Entities.Sales.Customer as a')
            .rightJoin('my.Entities.Sales.Order as b')
            .on('a.ID = b.customer_ID')
            .columns(['a.ID', 'a.name', 'a.city', { 'b.ID': 'Order_id' },
                { 'b.orderNo': 'OrderNo' }, { 'b.amount': 'order_ammount' }]);
        // return RightJoinData;

        // 3. Full Outer Join
        let FullJoinData = await SELECT.from('my.Entities.Sales.Customer as a')
            .fullJoin('my.Entities.Sales.Order as b')
            .on('a.ID = b.customer_ID')
            .columns(['a.ID', 'a.name', 'a.city', { 'b.ID': 'Order_id' },
                { 'b.orderNo': 'OrderNo' }, { 'b.amount': 'order_ammount' }]);
        return FullJoinData;

    });

    srv.after('READ', 'Customer', async (data, req) => {
        if (data.length > 0) {
            req.notify(200, 'Data founded!');
        }
        else {
            return req.reject(404, 'No customers with orders found');
        }
    });

});