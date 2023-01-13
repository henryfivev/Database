import sys
import pymysql
import getpass


def execute_query(query):
    cursor = conn.cursor()
    print(query)
    try:
        cursor.execute(query)
    except pymysql.err.ProgrammingError as e:
        print(e)
        print('Query failed. Check syntax.')
        return -1
    except pymysql.err.OperationalError as e:
        print(e)
        print('Query failed. Check table name and column names.')
        return -1
    except pymysql.err.IntegrityError as e:
        print(e)
        print('Query failed. Check for duplicate entries.')
        return -1
    else:
        print('Query successful.')
        return cursor.fetchall()


def activate_role():
    query = 'SET GLOBAL activate_all_roles_on_login=ON;'
    execute_query(query)


def select_all(table):
    query = 'SELECT * FROM {}'.format(table)
    return execute_query(query)


def select_all_where(table, column, value):
    query = "SELECT * FROM {} WHERE {} = '{}'".format(table, column, value)
    return execute_query(query)


def fuzzy_select_all_where(table, column, value):
    query = "SELECT * FROM {} WHERE {} LIKE '%{}%'".format(
        table, column, value)
    return execute_query(query)


def select_where(table, columns, where_column, where_value):
    query = 'SELECT {} FROM {} WHERE {} = {}'.format(
        columns, table, where_column, where_value)
    return execute_query(query)


def create_user(username, password):
    query = "CREATE USER '{}'@localhost IDENTIFIED BY '{}'".format(
        username, password)
    execute_query(query)
    conn.commit()


def delete_user(username):
    permission = get_permission_entry(username)
    if permission != 0:
        del_permission_entry(username)
    query = "DROP USER '{}'@localhost".format(username)
    execute_query(query)
    conn.commit()


def add_permission_entry(username, permission):
    query = "INSERT INTO user(username,permission) VALUES('{}',{})".format(
        username, permission)
    execute_query(query)
    conn.commit()


def get_permission_entry(username):
    query = "SELECT permission FROM user WHERE username = '{}'".format(
        username)
    try:
        return execute_query(query)[0][0]
    except IndexError:
        return 0


def del_permission_entry(username):
    query = "DELETE FROM user WHERE username = '{}'".format(username)
    execute_query(query)
    conn.commit()


def add_customer(name, address, phone):
    query = "INSERT INTO customer(name, address, phone) VALUES('{}', '{}', '{}')".format(
        name, address, phone)
    ret = execute_query(query)
    conn.commit()
    if ret != -1:
        print('Customer added successfully.')


def add_order(custkey, itemkey, quantity):
    query = "INSERT INTO orders(custkey,itemkey,quantity) VALUES({}, {}, {})".format(
        custkey, itemkey, quantity)
    ret = execute_query(query)
    conn.commit()
    if ret != -1:
        print('Order added successfully.')


def add_supplier(name, address, phone):
    query = "INSERT INTO supplier(name, address, phone) VALUES('{}', '{}', '{}')".format(
        name, address, phone)
    ret = execute_query(query)
    conn.commit()
    if ret != -1:
        print('Supplier added successfully.')


def add_supply(suppkey, itemkey, quantity):
    query = "INSERT INTO supply(suppkey,itemkey,quantity) VALUES({}, {}, {})".format(
        suppkey, itemkey, quantity)
    ret = execute_query(query)
    conn.commit()
    if ret != -1:
        print('Supply added successfully.')


def add_item(name, stock, retailprice, cost):
    query = "INSERT INTO item(name, stock, retailprice, cost) VALUES('{}', {}, {}, {})".format(
        name, stock, retailprice, cost)
    ret = execute_query(query)
    conn.commit()
    if ret != -1:
        print('Item added successfully.')


def update(table, column, value, where_column, where_value):
    query = "UPDATE {} SET {} = '{}' WHERE {} = '{}'".format(
        table, column, value, where_column, where_value)
    ret = execute_query(query)
    conn.commit()
    if ret != -1:
        print('Update successful.')


def delete(table, where_column, where_value):
    query = "DELETE FROM {} WHERE {} = '{}'".format(
        table, where_column, where_value)
    ret = execute_query(query)
    conn.commit()
    if ret != -1:
        print('Delete successful.')


def grant_privilege(username, perm):
    ret = None
    if perm == 10:
        query = "GRANT SalesToCRole TO '{}'@localhost".format(username)
        ret = execute_query(query)
        conn.commit()
    elif perm == 20:
        query = "GRANT SalesToBRole TO '{}'@localhost".format(username)
        ret = execute_query(query)
        conn.commit()
    elif perm == 30:
        query = "GRANT ItemManagerRole TO '{}'@localhost".format(username)
        ret = execute_query(query)
        conn.commit()
    elif perm == 100:
        query = "GRANT ManagerRole TO '{}'@localhost".format(username)
        ret = execute_query(query)
        conn.commit()
    elif perm == 255:
        query = "GRANT ALL PRIVILEGES ON *.* TO '{}'@localhost".format(
            username)
        ret = execute_query(query)
        conn.commit()
    if ret != -1:
        add_permission_entry(username, perm)


def revoke_privilege(username, perm):
    ret = None
    if perm == 10:
        query = "REVOKE SalesToCRole FROM '{}'@localhost".format(username)
        ret = execute_query(query)
        conn.commit()
    elif perm == 20:
        query = "REVOKE SalesToBRole FROM '{}'@localhost".format(username)
        ret = execute_query(query)
        conn.commit()
    elif perm == 30:
        query = "REVOKE ItemManagerRole FROM '{}'@localhost".format(username)
        ret = execute_query(query)
        conn.commit()
    elif perm == 100:
        query = "REVOKE ManagerRole FROM '{}'@localhost".format(username)
        ret = execute_query(query)
        conn.commit()
    elif perm == 255:
        query = "REVOKE ALL PRIVILEGES ON *.* FROM '{}'@localhost".format(
            username)
        ret = execute_query(query)
        conn.commit()
    if ret != -1:
        del_permission_entry(username)


def old():
    perm = get_permission_entry(user)
    while True:
        if perm == 0 and user != 'root':
            print('You do not have permission to access the database')
            conn.close()
            sys.exit(0)
        if perm == 10:
            print('You are a salesperson')
            print('Select the operation to perform:')
            print('1. Add customer')
            print('2. Search customer')
            print('3. Add orders')
            print('4. Search orders')
            print('5. Search products')
            print('q. quit')

            choice = input('Enter choice: ')
            if choice == '1':
                name = input('Enter name: ')
                phone = input('Enter phone: ')
                add_customer(name, phone)
            elif choice == '2':
                print('Search by:')
                print('1. Name')
                print('2. Phone')
                choices = input('Enter choice: ')
                if choices == '1':
                    name = input('Enter name: ')
                    print(select_all_where('customer', 'name', name))
                elif choices == '2':
                    phone = input('Enter phone: ')
                    print(select_all_where('customer', 'phone', phone))
            elif choice == '3':
                custkey = input('Enter customer key: ')
                totalprice = input('Enter total price: ')
                add_order(custkey, totalprice)
            elif choice == '4':
                custkey = input('Enter customer key: ')
                print(select_all_where('orders', 'custkey', custkey))
            elif choice == '5':
                name = input('Enter name: ')
                print(select_all_where('item', 'name', name))
            elif choice == 'q':
                conn.close()
                sys.exit(0)
        elif perm == 20:
            print('You are a Corporate Sales')
            print('Select the operation to perform:')
            print('1. Add supplier')
            print('2. Search supplier')
            print('3. Add supply')
            print('4. Search supply')
            print('5. Search products')
            print('q. quit')

            choice = input('Enter choice: ')
            if choice == '1':
                name = input('Enter name: ')
                address = input('Enter address: ')
                phone = input('Enter phone: ')
                add_supplier(name, address, phone)
            elif choice == '2':
                print('Search by:')
                print('1. Name')
                print('2. Address')
                print('3. Phone')
                choices = input('Enter choice: ')
                if choices == '1':
                    name = input('Enter name: ')
                    print(select_all_where('supplier', 'name', name))
                elif choices == '2':
                    address = input('Enter address: ')
                    print(select_all_where('supplier', 'address', address))
                elif choices == '3':
                    phone = input('Enter phone: ')
                    print(select_all_where('supplier', 'phone', phone))
            elif choice == '3':
                itemkey = input('Enter item key: ')
                suppkey = input('Enter supplier key: ')
                quantity = input('Enter quantity: ')
                cost = input('Enter cost: ')
                add_supply(itemkey, suppkey, quantity, cost)
            elif choice == '4':
                print('Search by:')
                print('1. Item key')
                print('2. Supplier key')
                choices = input('Enter choice: ')
                if choices == '1':
                    itemkey = input('Enter item key: ')
                    print(select_all_where('supply', 'itemkey', itemkey))
                elif choices == '2':
                    suppkey = input('Enter supplier key: ')
                    print(select_all_where('supply', 'suppkey', suppkey))
            elif choice == '5':
                print('Search by:')
                print('1. Name')
                print('2. itemkey')
                choices = input('Enter choice: ')
                if choices == '1':
                    name = input('Enter name: ')
                    print(fuzzy_select_all_where('item', 'name', name))
                elif choices == '2':
                    itemkey = input('Enter item key: ')
                    print(select_all_where('item', 'itemkey', itemkey))
            elif choice == 'q':
                conn.close()
                sys.exit(0)
        elif perm == 100:
            print('You are a manager')
            print('Select the operation to perform:')
            print('1. Add entry')
            print('2. Delete entry')
            print('3. Update entry')
            print('4. Search entry')
            print('5. Create user')
            print('6. Delete user')
            print('7. Grant permission')
            print('8. Revoke permission')
            print('q. quit')
        elif perm == 255 or user == 'root':
            print('You are an admin')
            print('Select the operation to perform:')
            print('1. Create user')
            print('2. Delete user')
            print('3. Grant permission')
            print('4. Revoke permission')
            print('5. Execute query')
            print('q. quit')
            choice = input('Enter choice: ')
            if choice == '1':
                username = input('Enter username: ')
                password = getpass.getpass('Enter password: ')
                create_user(username, password)
            elif choice == '2':
                username = input('Enter username: ')
                delete_user(username)
            elif choice == '3':
                username = input('Enter username: ')
                print('Select permission:')
                print('1. Salesperson')
                print('2. Corporate Sales')
                print('3. Manager')
                print('4. Admin')
                permission = input('Enter choice: ')
                if permission == '1':
                    permission = 10
                    grant_privilege(username, permission)
                elif permission == '2':
                    permission = 20
                    grant_privilege(username, permission)
                elif permission == '3':
                    permission = 100
                    grant_privilege(username, permission)
                elif permission == '4':
                    permission = 255
                    grant_privilege(username, permission)
            elif choice == '4':
                username = input('Enter username: ')
                permission = get_permission_entry(username)
                ret = revoke_privilege(username, permission)
            elif choice == '5':
                query = input('Enter query: ')
                ret = execute_query(query)
                if ret:
                    print(ret)
                conn.commit()
            elif choice == 'q':
                conn.close()
                sys.exit(0)

        else:
            conn.close()
            sys.exit(0)


def sales_interface():
    print('You are a Salesperson')
    print('Select the operation to perform:')
    print('1. Add customer')
    print('2. Search customer')
    print('3. Add order')
    print('4. Search order')
    print('5. Search products')
    print('q. quit')

    choice = input('Enter choice: ')
    if choice == '1':
        name = input('Enter name: ')
        address = input('Enter address: ')
        phone = input('Enter phone: ')
        add_customer(name, address, phone)
    elif choice == '2':
        print('Search by:')
        print('1. Name')
        print('2. Address')
        print('3. Phone')
        choices = input('Enter choice: ')
        if choices == '1':
            name = input('Enter name: ')
            ret = select_all_where('customer', 'name', name)
            if not ret:
                print('Not found')
                return
            ret = ret[0]
            print('Found customer with custkey: {}, name: {}, address: {}, phone: {}'.format(
                ret[0], ret[1], ret[2], ret[3]))
        elif choices == '2':
            address = input('Enter address: ')
            ret = select_all_where('customer', 'address', address)
            if not ret:
                print('Not found')
                return
            ret = ret[0]
            print('Found customer with custkey: {}, name: {}, address: {}, phone: {}'.format(
                ret[0], ret[1], ret[2], ret[3]))
        elif choices == '3':
            phone = input('Enter phone: ')
            ret = select_all_where('customer', 'phone', phone)
            if not ret:
                print('Not found')
                return
            ret = ret[0]
            print('Found customer with custkey: {}, name: {}, address: {}, phone: {}'.format(
                ret[0], ret[1], ret[2], ret[3]))
    elif choice == '3':
        custkey = input('Enter customer key: ')
        itemkey = input('Enter item key: ')
        quantity = input('Enter quantity: ')
        add_order(custkey, itemkey, quantity)
    elif choice == '4':
        print('Search by:')
        print('1. Customer key')
        print('2. Item key')
        choices = input('Enter choice: ')
        if choices == '1':
            custkey = input('Enter customer key: ')
            ret = select_all_where('orders', 'custkey', custkey)
            if not ret:
                print('Not found')
                return
            for i in ret:
                print('Found order with orderkey: {}, custkey: {}, itemkey: {}, quantity: {}, total: {}'.format(
                    i[0], i[1], i[2], i[3], i[4]))
        elif choices == '2':
            itemkey = input('Enter item key: ')
            ret = select_all_where('orders', 'itemkey', itemkey)
            if not ret:
                print('Not found')
                return
            for i in ret:
                print('Found order with orderkey: {}, custkey: {}, itemkey: {}, quantity: {}, total: {}'.format(
                    i[0], i[1], i[2], i[3], i[4]))
    elif choice == '5':
        print('Search by:')
        print('1. Name')
        print('2. itemkey')
        choices = input('Enter choice: ')
        if choices == '1':
            name = input('Enter name: ')
            ret = select_all_where('item', 'name', name)
            if not ret:
                print('Not found')
                return
            for i in ret:
                print('Found item with itemkey: {}, name: {}, price: {}'.format(
                    i[0], i[1], i[3]))
        elif choices == '2':
            itemkey = input('Enter item key: ')
            ret = select_all_where('item', 'itemkey', itemkey)
            if not ret:
                print('Not found')
                return
            for i in ret:
                print('Found item with itemkey: {}, name: {}, price: {}'.format(
                    i[0], i[1], i[3]))
    elif choice == 'q':
        conn.close()
        sys.exit(0)


def corps_interface():
    print('You are a Corporate Sales')
    print('Select the operation to perform:')
    print('1. Add supplier')
    print('2. Search supplier')
    print('3. Add supply')
    print('4. Search supply')
    print('5. Search products')
    print('q. quit')

    choice = input('Enter choice: ')
    if choice == '1':
        name = input('Enter name: ')
        address = input('Enter address: ')
        phone = input('Enter phone: ')
        add_supplier(name, address, phone)
    elif choice == '2':
        print('Search by:')
        print('1. Name')
        print('2. Address')
        print('3. Phone')
        choices = input('Enter choice: ')
        if choices == '1':
            name = input('Enter name: ')
            ret = select_all_where('supplier', 'name', name)
            if not ret:
                print('Not found')
                return
            ret = ret[0]
            print('Found supplier with suppkey: {}, name: {}, address: {}, phone: {}'.format(
                ret[0], ret[1], ret[2], ret[3]))
        elif choices == '2':
            address = input('Enter address: ')
            ret = select_all_where('supplier', 'address', address)
            if not ret:
                print('Not found')
                return
            ret = ret[0]
            print('Found supplier with suppkey: {}, name: {}, address: {}, phone: {}'.format(
                ret[0], ret[1], ret[2], ret[3]))
        elif choices == '3':
            phone = input('Enter phone: ')
            ret = select_all_where('supplier', 'phone', phone)
            if not ret:
                print('Not found')
                return
            ret = ret[0]
            print('Found supplier with suppkey: {}, name: {}, address: {}, phone: {}'.format(
                ret[0], ret[1], ret[2], ret[3]))
    elif choice == '3':
        suppkey = input('Enter supplier key: ')
        itemkey = input('Enter item key: ')
        quantity = input('Enter quantity: ')
        add_supply(suppkey, itemkey, quantity)
    elif choice == '4':
        print('Search by:')
        print('1. Supplier key')
        print('2. Item key')
        choices = input('Enter choice: ')
        if choices == '1':
            suppkey = input('Enter supplier key: ')
            ret = select_all_where('supply', 'suppkey', suppkey)
            if not ret:
                print('Not found')
                return
            for i in ret:
                print('Found supply with suppkey: {}, itemkey: {}, quantity: {}, total: {}'.format(
                    i[1], i[2], i[3], i[4]))
        elif choices == '2':
            itemkey = input('Enter item key: ')
            ret = select_all_where('supply', 'itemkey', itemkey)
            if not ret:
                print('Not found')
                return
            for i in ret:
                print('Found supply with suppkey: {}, itemkey: {}, quantity: {}, total: {}'.format(
                    i[1], i[2], i[3], i[4]))
    elif choice == '5':
        print('Search by:')
        print('1. Name')
        print('2. itemkey')
        choices = input('Enter choice: ')
        if choices == '1':
            name = input('Enter name: ')
            ret = select_all_where('item', 'name', name)
            if not ret:
                print('Not found')
                return
            for i in ret:
                print('Found item with itemkey: {}, name: {}, cost: {}'.format(
                    i[0], i[1], i[4]))
        elif choices == '2':
            itemkey = input('Enter item key: ')
            ret = select_all_where('item', 'itemkey', itemkey)
            if not ret:
                print('Not found')
                return
            for i in ret:
                print('Found item with itemkey: {}, name: {}, cost: {}'.format(
                    i[0], i[1], i[4]))
    elif choice == 'q':
        conn.close()
        sys.exit(0)


def item_interface():
    print('You are an Item Manager')
    print('Select the operation to perform:')
    print('1. Add item')
    print('2. Search item')
    print('3. Search order')
    print('4. Search supply')
    print('q. quit')

    choice = input('Enter choice: ')
    if choice == '1':
        name = input('Enter name: ')
        stock = input('Enter stock: ')
        price = input('Enter price: ')
        cost = input('Enter cost: ')
        add_item(name, stock, price, cost)
    elif choice == '2':
        print('Search by:')
        print('1. Name')
        print('2. itemkey')
        choices = input('Enter choice: ')
        if choices == '1':
            name = input('Enter name: ')
            ret = select_all_where('item', 'name', name)
            if not ret:
                print('Not found')
                return
            for i in ret:
                print('Found item with itemkey: {}, name: {}, stock: {}, price: {}, cost: {}'.format(
                    i[0], i[1], i[2], i[3], i[4]))
        elif choices == '2':
            itemkey = input('Enter item key: ')
            ret = select_all_where('item', 'itemkey', itemkey)
            if not ret:
                print('Not found')
                return
            for i in ret:
                print('Found item with itemkey: {}, name: {}, stock: {}, price: {}, cost: {}'.format(
                    i[0], i[1], i[2], i[3], i[4]))
    elif choice == '3':
        print('Search by:')
        print('1. Order key')
        print('2. Item key')
        choices = input('Enter choice: ')
        if choices == '1':
            orderkey = input('Enter order key: ')
            ret = select_all_where('order', 'orderkey', orderkey)
            if not ret:
                print('Not found')
                return
            for i in ret:
                print('Found order with orderkey: {}, custkey: {}, itemkey: {}, quantity: {}'.format(
                    i[0], i[1], i[2], i[3]))
        elif choices == '2':
            itemkey = input('Enter item key: ')
            ret = select_all_where('order', 'itemkey', itemkey)
            if not ret:
                print('Not found')
                return
            for i in ret:
                print('Found order with orderkey: {}, custkey: {}, itemkey: {}, quantity: {}'.format(
                    i[0], i[1], i[2], i[3]))
    elif choice == '4':
        print('Search by:')
        print('1. Supplier key')
        print('2. Item key')
        choices = input('Enter choice: ')
        if choices == '1':
            suppkey = input('Enter supplier key: ')
            ret = select_all_where('supply', 'suppkey', suppkey)
            if not ret:
                print('Not found')
                return
            for i in ret:
                print('Found supply with suppkey: {}, itemkey: {}, quantity: {}'.format(
                    i[0], i[1], i[2]))
        elif choices == '2':
            itemkey = input('Enter item key: ')
            ret = select_all_where('supply', 'itemkey', itemkey)
            if not ret:
                print('Not found')
                return
            for i in ret:
                print('Found supply with suppkey: {}, itemkey: {}, quantity: {}'.format(
                    i[0], i[1], i[2]))
    elif choice == 'q':
        conn.close()
        sys.exit(0)


def manager_interface():
    print('You are a Manager')
    print('Select the operation to perform:')
    print('1. Add entry')
    print('2. Search entry')
    print('3. Update entry')
    print('4. Delete entry')
    print('5. Create user')
    print('6. Delete user')
    print('7. Grant permission')
    print('8. Revoke permission')
    print('q. quit')

    choice = input('Enter choice: ')
    if choice == '1':
        print('Add to:')
        print('1. Customer')
        print('2. Supplier')
        print('3. Item')
        print('4. Order')
        print('5. Supply')
        choices = input('Enter choice: ')
        if choices == '1':
            name = input('Enter name: ')
            address = input('Enter address: ')
            phone = input('Enter phone: ')
            add_customer(name, address, phone)
        elif choices == '2':
            name = input('Enter name: ')
            address = input('Enter address: ')
            phone = input('Enter phone: ')
            add_supplier(name, address, phone)
        elif choices == '3':
            name = input('Enter name: ')
            stock = input('Enter stock: ')
            price = input('Enter price: ')
            cost = input('Enter cost: ')
            add_item(name, stock, price, cost)
        elif choices == '4':
            custkey = input('Enter customer key: ')
            itemkey = input('Enter item key: ')
            quantity = input('Enter quantity: ')
            add_order(custkey, itemkey, quantity)
        elif choices == '5':
            suppkey = input('Enter supplier key: ')
            itemkey = input('Enter item key: ')
            quantity = input('Enter quantity: ')
            add_supply(suppkey, itemkey, quantity)
    elif choice == '2':
        print('Search for:')
        print('1. Customer')
        print('2. Supplier')
        print('3. Item')
        print('4. Order')
        print('5. Supply')
        choices = input('Enter choice: ')
        if choices == '1':
            print('Search by:')
            print('1. Customer key')
            print('2. Customer name')
            print('3. Customer address')
            print('4. Customer phone')
            choices = input('Enter choice: ')
            if choices == '1':
                custkey = input('Enter customer key: ')
                ret = select_all_where('customer', 'custkey', custkey)
                if not ret:
                    print('Not found')
                    return
                for i in ret:
                    print('Found customer with custkey: {}, name: {}, address: {}, phone: {}'.format(
                        i[0], i[1], i[2], i[3]))
            elif choices == '2':
                name = input('Enter customer name: ')
                ret = select_all_where('customer', 'name', name)
                if not ret:
                    print('Not found')
                    return
                for i in ret:
                    print('Found customer with custkey: {}, name: {}, address: {}, phone: {}'.format(
                        i[0], i[1], i[2], i[3]))
            elif choices == '3':
                address = input('Enter customer address: ')
                ret = select_all_where('customer', 'address', address)
                if not ret:
                    print('Not found')
                    return
                for i in ret:
                    print('Found customer with custkey: {}, name: {}, address: {}, phone: {}'.format(
                        i[0], i[1], i[2], i[3]))
            elif choices == '4':
                phone = input('Enter customer phone: ')
                ret = select_all_where('customer', 'phone', phone)
                if not ret:
                    print('Not found')
                    return
                for i in ret:
                    print('Found customer with custkey: {}, name: {}, address: {}, phone: {}'.format(
                        i[0], i[1], i[2], i[3]))
        elif choices == '2':
            print('Search by:')
            print('1. Supplier key')
            print('2. Supplier name')
            print('3. Supplier address')
            print('4. Supplier phone')
            choices = input('Enter choice: ')
            if choices == '1':
                suppkey = input('Enter supplier key: ')
                ret = select_all_where('supplier', 'suppkey', suppkey)
                if not ret:
                    print('Not found')
                    return
                for i in ret:
                    print('Found supplier with suppkey: {}, name: {}, address: {}, phone: {}'.format(
                        i[0], i[1], i[2], i[3]))
            elif choices == '2':
                name = input('Enter supplier name: ')
                ret = select_all_where('supplier', 'name', name)
                if not ret:
                    print('Not found')
                    return
                for i in ret:
                    print('Found supplier with suppkey: {}, name: {}, address: {}, phone: {}'.format(
                        i[0], i[1], i[2], i[3]))
            elif choices == '3':
                address = input('Enter supplier address: ')
                ret = select_all_where('supplier', 'address', address)
                if not ret:
                    print('Not found')
                    return
                for i in ret:
                    print('Found supplier with suppkey: {}, name: {}, address: {}, phone: {}'.format(
                        i[0], i[1], i[2], i[3]))
            elif choices == '4':
                phone = input('Enter supplier phone: ')
                ret = select_all_where('supplier', 'phone', phone)
                if not ret:
                    print('Not found')
                    return
                for i in ret:
                    print('Found supplier with suppkey: {}, name: {}, address: {}, phone: {}'.format(
                        i[0], i[1], i[2], i[3]))
        elif choices == '3':
            print('Search by:')
            print('1. Item key')
            print('2. Item name')
            choices = input('Enter choice: ')
            if choices == '1':
                itemkey = input('Enter item key: ')
                ret = select_all_where('item', 'itemkey', itemkey)
                if not ret:
                    print('Not found')
                    return
                for i in ret:
                    print('Found item with itemkey: {}, name: {}, stock: {}, price: {}, cost: {}'.format(
                        i[0], i[1], i[2], i[3], i[4]))
            elif choices == '2':
                name = input('Enter item name: ')
                ret = select_all_where('item', 'name', name)
                if not ret:
                    print('Not found')
                    return
                for i in ret:
                    print('Found item with itemkey: {}, name: {}, stock: {}, price: {}, cost: {}'.format(
                        i[0], i[1], i[2], i[3], i[4]))
        elif choices == '4':
            print('Search by:')
            print('1. Order key')
            print('2. Customer key')
            print('3. Item key')
            choices = input('Enter choice: ')
            if choices == '1':
                orderkey = input('Enter order key: ')
                ret = select_all_where('orders', 'orderkey', orderkey)
                if not ret:
                    print('Not found')
                    return
                for i in ret:
                    print('Found order with orderkey: {}, custkey: {}, itemkey: {}, quantity: {}, totalprice: {}, profit: {}'.format(
                        i[0], i[1], i[2], i[3], i[4], i[5]))
            elif choices == '2':
                custkey = input('Enter customer key: ')
                ret = select_all_where('orders', 'custkey', custkey)
                if not ret:
                    print('Not found')
                    return
                for i in ret:
                    print('Found order with orderkey: {}, custkey: {}, itemkey: {}, quantity: {}, totalprice: {}, profit: {}'.format(
                        i[0], i[1], i[2], i[3], i[4], i[5]))
            elif choices == '3':
                itemkey = input('Enter item key: ')
                ret = select_all_where('orders', 'itemkey', itemkey)
                if not ret:
                    print('Not found')
                    return
                for i in ret:
                    print('Found order with orderkey: {}, custkey: {}, itemkey: {}, quantity: {}, totalprice: {}, profit: {}'.format(
                        i[0], i[1], i[2], i[3], i[4], i[5]))
        elif choices == '5':
            print('Search by:')
            print('1. Supplier key')
            print('2. Item key')
            choices = input('Enter choice: ')
            if choices == '1':
                suppkey = input('Enter supplier key: ')
                ret = select_all_where('supply', 'suppkey', suppkey)
                if not ret:
                    print('Not found')
                    return
                for i in ret:
                    print('Found supply with id: {}, suppkey: {}, itemkey: {}, quantity: {}, totalcost: {}'.format(
                        i[0], i[1], i[2], i[3], i[4]))
            elif choices == '2':
                itemkey = input('Enter item key: ')
                ret = select_all_where('supply', 'itemkey', itemkey)
                if not ret:
                    print('Not found')
                    return
                for i in ret:
                    print('Found supply with id: {}, suppkey: {}, itemkey: {}, quantity: {}, totalcost: {}'.format(
                        i[0], i[1], i[2], i[3], i[4]))
    elif choice == '3':
        print('Select the table to update:')
        print('1. Customer')
        print('2. Supplier')
        print('3. Item')
        print('4. Order')
        print('5. Supply')
        choices = input('Enter choice: ')
        if choices == '1':
            custkey = input('Enter customer key: ')
            print('Select the column to update:')
            print('1. Name')
            print('2. Address')
            print('3. Phone')
            choices = input('Enter choice: ')
            if choices == '1':
                name = input('Enter new name: ')
                update('customer', 'name', name, 'custkey', custkey)
            elif choices == '2':
                address = input('Enter new address: ')
                update('customer', 'address', address, 'custkey', custkey)
            elif choices == '3':
                phone = input('Enter new phone: ')
                update('customer', 'phone', phone, 'custkey', custkey)
        elif choices == '2':
            suppkey = input('Enter supplier key: ')
            print('Select the column to update:')
            print('1. Name')
            print('2. Address')
            print('3. Phone')
            choices = input('Enter choice: ')
            if choices == '1':
                name = input('Enter new name: ')
                update('supplier', 'name', name, 'suppkey', suppkey)
            elif choices == '2':
                address = input('Enter new address: ')
                update('supplier', 'address', address, 'suppkey', suppkey)
            elif choices == '3':
                phone = input('Enter new phone: ')
                update('supplier', 'phone', phone, 'suppkey', suppkey)
        elif choices == '3':
            itemkey = input('Enter item key: ')
            print('Select the column to update:')
            print('1. Name')
            print('2. Stock')
            print('3. Price')
            print('4. Cost')
            choices = input('Enter choice: ')
            if choices == '1':
                name = input('Enter new name: ')
                update('item', 'name', name, 'itemkey', itemkey)
            elif choices == '2':
                stock = input('Enter new stock: ')
                update('item', 'stock', stock, 'itemkey', itemkey)
            elif choices == '3':
                price = input('Enter new price: ')
                update('item', 'price', price, 'itemkey', itemkey)
            elif choices == '4':
                cost = input('Enter new cost: ')
                update('item', 'cost', cost, 'itemkey', itemkey)
        elif choices == '4':
            orderkey = input('Enter order key: ')
            print('Select the column to update:')
            print('1. Quantity')
            print('2. Total price')
            print('3. Profit')
            choices = input('Enter choice: ')
            if choices == '1':
                quantity = input('Enter new quantity: ')
                update('orders', 'quantity', quantity, 'orderkey', orderkey)
            elif choices == '2':
                totalprice = input('Enter new total price: ')
                update('orders', 'totalprice',
                       totalprice, 'orderkey', orderkey)
            elif choices == '3':
                profit = input('Enter new profit: ')
                update('orders', 'profit', profit, 'orderkey', orderkey)
        elif choices == '5':
            id = input('Enter id: ')
            print('Select the column to update:')
            print('1. Quantity')
            print('2. Total cost')
            choices = input('Enter choice: ')
            if choices == '1':
                quantity = input('Enter new quantity: ')
                update('supply', 'quantity', quantity, 'id', id)
            elif choices == '2':
                totalcost = input('Enter new total cost: ')
                update('supply', 'totalcost', totalcost, 'id', id)
    elif choice == '4':
        print('Select the table to delete from:')
        print('1. Customer')
        print('2. Supplier')
        print('3. Item')
        print('4. Order')
        print('5. Supply')
        choices = input('Enter choice: ')
        if choices == '1':
            custkey = input('Enter customer key: ')
            delete('customer', 'custkey', custkey)
        elif choices == '2':
            suppkey = input('Enter supplier key: ')
            delete('supplier', 'suppkey', suppkey)
        elif choices == '3':
            itemkey = input('Enter item key: ')
            delete('item', 'itemkey', itemkey)
        elif choices == '4':
            orderkey = input('Enter order key: ')
            delete('orders', 'orderkey', orderkey)
        elif choices == '5':
            id = input('Enter id: ')
            delete('supply', 'id', id)
    elif choice == '5':
        username = input('Enter username: ')
        password = getpass.getpass('Enter password: ')
        create_user(username, password)
    elif choice == '6':
        username = input('Enter username: ')
        delete_user(username)
    elif choice == '7':
        username = input('Enter username: ')
        print('Select permission:')
        print('1. Salesperson')
        print('2. Corporate Sales')
        print('3. Item Manager')
        print('4. Manager')
        permission = input('Enter choice: ')
        if permission == '1':
            permission = 10
            grant_privilege(username, permission)
        elif permission == '2':
            permission = 20
            grant_privilege(username, permission)
        elif permission == '3':
            permission = 30
            grant_privilege(username, permission)
        elif permission == '4':
            permission = 100
            grant_privilege(username, permission)
    elif choice == '8':
        username = input('Enter username: ')
        permission = get_permission_entry(username)
        ret = revoke_privilege(username, permission)
    elif choice == 'q':
        conn.close()
        sys.exit(0)


def admin_interface():
    print('You are an admin')
    print('Select the operation to perform:')
    print('1. Create user')
    print('2. Delete user')
    print('3. Grant permission')
    print('4. Revoke permission')
    print('5. Execute query')
    print('6. Activate role')
    print('q. quit')
    choice = input('Enter choice: ')
    if choice == '1':
        username = input('Enter username: ')
        password = getpass.getpass('Enter password: ')
        create_user(username, password)
    elif choice == '2':
        username = input('Enter username: ')
        delete_user(username)
    elif choice == '3':
        username = input('Enter username: ')
        print('Select permission:')
        print('1. Salesperson')
        print('2. Corporate Sales')
        print('3. Item Manager')
        print('4. Manager')
        print('5. Admin')
        permission = input('Enter choice: ')
        if permission == '1':
            permission = 10
            grant_privilege(username, permission)
        elif permission == '2':
            permission = 20
            grant_privilege(username, permission)
        elif permission == '3':
            permission = 30
            grant_privilege(username, permission)
        elif permission == '4':
            permission = 100
            grant_privilege(username, permission)
        elif permission == '5':
            permission = 255
            grant_privilege(username, permission)
    elif choice == '4':
        username = input('Enter username: ')
        permission = get_permission_entry(username)
        ret = revoke_privilege(username, permission)
    elif choice == '5':
        query = input('Enter query: ')
        ret = execute_query(query)
        if ret:
            print(ret)
        conn.commit()
    elif choice == '6':
        activate_role()
    elif choice == 'q':
        conn.close()
        sys.exit(0)


def main():
    global user, conn
    host = 'localhost'
    user = 'salesperson'
    password = 'dsbdsb'
    database = 'exp'
    try:
        conn = pymysql.connect(host=host, user=user,
                               password=password, database=database, autocommit=True)
    except pymysql.err.OperationalError as e:
        print(e)
        print('Connection failed. Check username and password.')
        sys.exit(0)
    else:
        print('Connection established')
        print('Welcome to the database')

    perm = get_permission_entry(user)
    while True:
        if perm == 0 and not user == 'root':
            print('You do not have permission to access the database')
            conn.close()
            sys.exit(0)
        elif perm == 10:
            sales_interface()
        elif perm == 20:
            corps_interface()
        elif perm == 30:
            item_interface()
        elif perm == 100:
            manager_interface()
        elif perm == 255 or user == 'root':
            admin_interface()
        else:
            conn.close()
            sys.exit(0)


main()
''' 
Database structure
CREATE TABLE customer (
	custkey INT PRIMARY KEY,
	`name` CHAR ( 25 ),
    address VARCHAR ( 100 ),
	phone CHAR ( 15 )
);

CREATE TABLE supplier (
	suppkey INT PRIMARY KEY,
	`name` VARCHAR ( 100 ),
	address VARCHAR ( 100 ),
    phone CHAR ( 15 ) 
);

CREATE TABLE item (
	itemkey INT PRIMARY KEY,
	`name` VARCHAR ( 50 ),
	stock INT,
	retailprice REAL,
    cost REAL 
);

CREATE TABLE orders (
	orderkey INT PRIMARY KEY,
	custkey INT REFERENCES customer ( custkey ),
	itemkey INT REFERENCES item ( itemkey ),
	quantity INT,
    totalprice REAL,
    profit REAL
);

CREATE TABLE supply (
	id INT PRIMARY KEY,
	suppkey INT REFERENCES supplier ( suppkey ),
	itemkey INT REFERENCES item ( itemkey ),
	quantity INT,
    totalcost REAL 
);

CREATE TABLE USER (
	username VARCHAR ( 30 ) PRIMARY KEY,
    permission INT 
);
'''
