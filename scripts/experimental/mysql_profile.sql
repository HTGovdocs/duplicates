USE ht_repository;
SET @@profiling = 0;
DELETE FROM holdings_htitem_oclc_tmp;
SET @@profiling_history_size = 0;
SET @@profiling_history_size = 100;
SET @@profiling = 1;
INSERT INTO holdings_htitem_oclc_tmp (volume_id, oclc, origin) VALUES ('foo.001', '2001', '101');
INSERT INTO holdings_htitem_oclc_tmp (volume_id, oclc, origin) VALUES ('foo.002', '2002', '102');
INSERT INTO holdings_htitem_oclc_tmp (volume_id, oclc, origin) VALUES ('foo.003', '2003', '103');
SHOW profiles;
SHOW profile;
SET @@profiling = 0;