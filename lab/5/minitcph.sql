CREATE TABLE `产品目录`  (
  `pro_name` varchar(20) NOT NULL,
  `sup_name` varchar(40) NULL,
  PRIMARY KEY (`pro_name`)
);

CREATE TABLE `订单`  (
  `ord_customer` varchar(20) NOT NULL,
  `pro_name` varchar(20) NULL,
  `ord_price` decimal(10, 0) NULL,
  PRIMARY KEY (`ord_customer`)
);

CREATE TABLE `供应商`  (
  `sup_name` varchar(40) NOT NULL,
  `sup_address` varchar(40) NULL,
  PRIMARY KEY (`sup_name`)
);

ALTER TABLE `产品目录` ADD CONSTRAINT `fk_产品目录_供应商_1` FOREIGN KEY (`sup_name`) REFERENCES `供应商` (`sup_name`);
ALTER TABLE `订单` ADD CONSTRAINT `fk_订单_产品目录_1` FOREIGN KEY (`pro_name`) REFERENCES `产品目录` (`pro_name`);

