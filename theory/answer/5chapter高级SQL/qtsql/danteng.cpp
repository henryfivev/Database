#include <qsqlrecord.h>

#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QString>
#include <QtSql>
#include <iomanip>
#include <iostream>

void printTable(QString s) {}

int main(int argc, char *argv[]) {
  QSqlDatabase db = QSqlDatabase::addDatabase("QPSQL");
  db.setHostName("/var/run/postgresql");
  db.setUserName("sd44");
  db.setDatabaseName("mydb");
  if (!db.open()) {
    std::cout << "Unable to establish a database connection.\n";
    return EXIT_FAILURE;
  }

  // 这里用的SqlMOdel,其实直接用query也可以。
  QSqlQueryModel model;
  model.setQuery(
      "SELECT table_name, column_name, udt_name\
             FROM information_schema.columns\
             WHERE table_schema = 'public' or table_schema IS NULL\
             order by table_name, ordinal_position, column_name; ");
  int j = model.rowCount();

  // TODO
  // 我还不知道如何像使用std::cout控制字符宽度一样使用qDebug()，这里使用std::cout
  std::cout << std::setw(20) << "table_name" << std::setw(20) << "col_name"
            << std::setw(20) << "type_name" << std::endl;

  if (j == 0) {
    std::cout << "Empty Database " << std::endl;
  }
  for (int i = 0; i < model.rowCount(); i++) {
    std::cout << std::setw(20)
              << model.record(i).value(0).toString().toStdString()
              << std::setw(20)
              << model.record(i).value(1).toString().toStdString()
              << std::setw(20)
              << model.record(i).value(2).toString().toStdString() << std::endl;
  }
  return 0;
}
