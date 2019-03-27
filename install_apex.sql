-- APEX install
@apexins.sql SYSAUX SYSAUX TEMP /i/
-- APEX REST configuration
@apex_rest_config_core.sql oracle oracle
-- Required for ORDS install
alter user apex_public_user identified by oracle account unlock;
alter user apex_rest_public_user identified by oracle account unlock;
-- From Joels blog: http://joelkallman.blogspot.ca/2017/05/apex-and-ords-up-and-running-in2-steps.html
declare
    l_acl_path varchar2(4000);
    l_apex_schema varchar2(100);
begin
    for c1 in (select schema
                 from sys.dba_registry
                where comp_id = 'APEX') loop
        l_apex_schema := c1.schema;
    end loop;
    sys.dbms_network_acl_admin.append_host_ace(
        host => '*',
        ace => xs$ace_type(privilege_list => xs$name_list('connect'),
        principal_name => l_apex_schema,
        principal_type => xs_acl.ptype_db));
    commit;
end;
/
-- Setup APEX Admin password
begin
    apex_util.set_security_group_id(10);
    apex_util.create_user(
        p_user_name => 'ADMIN',
        p_email_address => 'bjarte.brandt@ougn.no',
        p_web_password => 'Welcome1',
        p_developer_privs => 'ADMIN',
        p_change_password_on_first_use => 'N');
    apex_util.set_security_group_id( null );
    commit;
end;
/
exit;
