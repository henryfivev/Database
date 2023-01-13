#include <iomanip>
#include <iostream>
#include <pqxx/pqxx>
#include <string>
#include <vector>

using namespace std;

// 如果使用libpq C库的话，直接使用PGprint函数就可以。
void printTable(const char *tabName, pqxx::work &wk) {
  pqxx::result r = wk.exec("SELECT * FROM " + wk.esc(tabName));
  // esc() 提供安全转义，防止SQL注入。

  for (auto i = 0; i < r.columns(); ++i) {
    cout << setw(15) << r.column_name(i);
  }
  cout << endl;
  for (auto const &row : r) {
    for (auto const &field : row) {
      // c_str()方法不支持二进制和blob等数据。如果想完全实现和可控的话，应当
      // 建立PostgreSQL数据类型到C++的类型映射表，脏活，累觉不爱。
      cout << setw(15) << field.c_str();
    }
    cout << endl;
  }
}

struct part {
  int part_id;
  string name;
  int cost;
  int subpart_id;
  int count;
};

int recur_calc(const vector<part> &p, int id) {
  int cost = 0;

  for (auto i = 0; i < p.size(); i++) {
    if (p[i].part_id == id) {
      cost += p[i].cost;
      break;
    }
  }
  // 没有找到 id，就返回0
  if (cost == 0) return cost;

  // p[i].count 如果等于0, 代表无需计算，或者subpart_id和count是空值
  for (auto i = 0; i < p.size(); i++) {
    if (p[i].part_id == id && p[i].count != 0) {
      cost += p[i].count * recur_calc(p, p[i].subpart_id);
    }
  }

  return cost;
}

int tot_cost(const string partname, pqxx::work &wk) {
  /////////////////////////////////////////////////////////////////////////////
  //                找到想要查找部件的ID,可单独建个函数 //
  /////////////////////////////////////////////////////////////////////////////
  pqxx::row part_row =
      wk.exec1("SELECT part_id FROM part WHERE name = " + wk.quote(partname));
  int id;                // 存储要找的部件ID
  if (part_row.empty())  //如果数据库中没有部件partname，返回0.
    return 0;

  part_row[0].to(id);

  /////////////////////////////////////////////////////////////////////////////
  //          构建一个完善的关系表，并将其数据存入c++程序内存 //
  /////////////////////////////////////////////////////////////////////////////

  vector<part> part_list;

  // 用了左外连接，设计上有点问题，会出现null值
  pqxx::result r = wk.exec(
      "SELECT part_id, name, cost, subpart_id, count\
       FROM part NATURAL LEFT JOIN subpart;");

  for (auto i : r) {
    part tmp;
    i[0].to(tmp.part_id);
    if (i[1].is_null())
      tmp.name = "fuck";
    else
      i[1].to(tmp.name);
    !i[2].is_null() ? i[2].to(tmp.cost) : tmp.cost = 0;

    // TODO FIXME DIRTY CODE
    // 因recur_calc函数中使用了左外连接，有可能造成subpart中字段为null，必须
    // 考虑处理null值。我将count设为0来标记null值。
    !i[3].is_null() ? i[3].to(tmp.subpart_id) : tmp.subpart_id = 0;
    !i[4].is_null() ? i[4].to(tmp.count) : tmp.count = 0;
    part_list.push_back(tmp);
  }
  // 测试语句，看是否正确存入
  // for (auto j : part_list)
  //   cout << j.part_id << '\t' << j.name << '\t' << j.subpart_id << endl;

  /////////////////////////////////////////////////////////////////////////////
  //                     进入正题，迭代计算某零件的总花销 //
  /////////////////////////////////////////////////////////////////////////////

  return recur_calc(part_list, id);
};

int main() {
  try {
    // URI连接，通过UNIX套接字
    // pqxx::connection c("postgresql:///mydb?connect_timeout=10");

    // URI连接，通过host
    pqxx::connection c(
        "postgresql://sd44:fuckyou@localhost:5432/mydb?connect_timeout=10");

    // Start a transaction.  In libpqxx, you always work in one.
    pqxx::work w(c);

    // prtin table "section"
    // printTable("section", w);

    // find part "P-100" total cost
    cout << "P-100's total cost is " << tot_cost("P-100", w) << endl;
    cout << "P-101's total cost is " << tot_cost("P-101", w) << endl;
    cout << "P-102's total cost is " << tot_cost("P-102", w) << endl;

    cout << "P-103's total cost is " << tot_cost("P-103", w) << endl;

    // Commit your transaction.  If an exception occurred before this
    // point, execution will have left the block, and the transaction will
    // have been destroyed along the way.  In that case, the failed
    // transaction would implicitly abort instead of getting to this point.
    w.commit();

  } catch (const exception &e) {
    cerr << e.what() << endl;
    return 1;
  }

  return 0;
}
