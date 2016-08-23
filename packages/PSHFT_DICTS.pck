create or replace package PSHFT_DICTS is

  -- Author  : BESO
  -- Created : 2/20/2013 3:00:24 PM
  -- Purpose : set of methods working with Dictionaries
  

  DCODE_OperRestrictGroup constant number := 24;
  
  
  DICT_ORDERBY_CODE constant number := 1;
  DICT_ORDERBY_NAME constant number := 2;
  DICT_ORDERBY_NAMETECH constant number := 3;
  
  
  -- type of Cursor referencing to the Resultset consisting of Dictionary Items (DIC_DATA) records
  TYPE DictDataCurTyp is ref cursor;
  -- type of Cursor referencing to the Resultset consisting of Dictionaries (DIC) records
  TYPE DictCurTyp is ref cursor;
  
  -- Returns Cursor for the indicated Dictionary items CODE and NAME values (this order), ordered by CODE
  -- Returned are following columns:
  -- CODE == Code of the Item (to be value of the choice on the UI control - ComoBox or List)
  -- NAME == Name of the Item (to be name on the UI control - ComoBox or List)
  -- #param p_dict_code Code of the Dictionary whose Items are of interest
  -- #param p_if_activeonly indicate if only Active Items are to be returned (1) or - ALL ones (0). 
  --        By Default - Active Items are returned only.
  -- #param p_orderby define ORDER BY clause for the ResultSet. Possible values are:
  -- <ul>
  -- <li>{#link DICT_ORDERBY_CODE} Items are ordered according CODE</li>
  -- <li>{#link DICT_ORDERBY_NAME} Items are ordered according NAME </li>
  -- <li>{#link DICT_ORDERBY_NAMETECH} Items are ordered according NAME_TECH </li>
  -- </ul>
  function getDictData(p_dict_code pls_integer, p_if_activeonly pls_integer := 1, p_orderby pls_integer := DICT_ORDERBY_CODE) return DictDataCurTyp;
  
  -- Returns open Cursor providing resultset of Dictionaries, depending on the Dictionary Code requested.
  -- #param p_dict_code indicate which Dictionaries should be present in the Resultset:
  -- if 0 - resultset will consist of ALL existing Dictionaries.
  -- if > 0 - resultset will consist of only 1 Dictonary, namely one having indicated Dictionary Code or 0 if Dictionary with this code - doesn't exist.
  function getDictDsc(p_dict_code pls_integer) return DictCurTyp;
  
  -- re-uses general getDictData(p_dict_code) method for Dictionary #24 (see DCODE_OperRestrictGroup)
  function getDictData_OperRestrGroup return DictDataCurTyp;

  function getNameByCode(p_dict_code number, p_item_code number) return varchar2;


end PSHFT_DICTS;
/
create or replace package body PSHFT_DICTS is

  function getDictData(p_dict_code pls_integer, p_if_activeonly pls_integer, p_orderby pls_integer) return DictDataCurTyp is
    /**
    declare
      p_dict_code pls_integer := 24;
      p_if_activeonly pls_integer := 1;
      p_orderby pls_integer := PSHFT_DICTS.DICT_ORDERBY_CODE;
      curData PSHFT_DICTS.DictDataCurTyp;
      recDict SHFT_DICT%ROWTYPE;
    begin
      curData := PSHFT_DICTS.getDictData(p_dict_code, p_if_activeonly, p_orderby);
      LOOP
        fetch curData into recDict;
        exit when curData%NOTFOUND;
        dbms_output.put_line('CODE = ' || recDict.CODE || ': ' || recDict.NAME);
      end loop;
    end;
    */
    curData DictDataCurTyp;
    v_where varchar2(200) := '';
    v_where_counter pls_integer := 0;
    v_orderby varchar2(200) := ' order by ';
    v_sql varchar2(2000);
  begin
    
    v_sql := 'select * from SHFT_DICT @WHERE @ORDERBY';

    --
    if p_dict_code > 0 then 
      v_where_counter := v_where_counter + 1;
      if v_where_counter > 1 then
        v_where := v_where || ' and ';
      else
        v_where := v_where || ' where ';
      end if;
      v_where := v_where || ' up = ' || p_dict_code;
    end if;  

    --
    if p_if_activeonly = 1 then 
      v_where_counter := v_where_counter + 1;
      if v_where_counter > 1 then
        v_where := v_where || ' and ';
      else
        v_where := v_where || ' where ';
      end if;
      v_where := v_where || ' activity_flag = 1 ';
    end if;  
    
    case p_orderby
      when DICT_ORDERBY_CODE then 
        v_orderby := v_orderby || ' code ';
      when DICT_ORDERBY_NAME then
        v_orderby := v_orderby || ' name ';
      when DICT_ORDERBY_NAMETECH then 
        v_orderby := v_orderby || ' name_tech ';
    end case;
    
    v_sql := replace(v_sql, '@WHERE', v_where);
    v_sql := replace(v_sql, '@ORDERBY', v_orderby);

    open curData for v_sql;
    return curData;
  end getDictData;



  function getDictData_OperrestrGroup return DictDataCurTyp is
  /**
  declare
    crs PSHFT_DICTS.DictDataCurTyp;
    v_code number; 
    v_name varchar2(64);
  begin
    crs := PSHFT_DICTS.getDictData_OperrestrGroup;
    LOOP
      fetch crs into v_code, v_name; 
      exit when crs%NOTFOUND;
    END LOOP;
    CLOSE crs; 
  end;
  */
    curData DictDataCurTyp;
  begin
    curData := getDictData(DCODE_OperRestrictGroup);
    return curData;
  end getDictData_OperrestrGroup;

  -- getNameByCode()
  function getNameByCode(p_dict_code number, p_item_code number) return varchar2 is
    v_name SHFT_DICT.NAME%TYPE;
  begin
    select name into v_name 
           from SHFT_DICT dd
           where dd.up = p_dict_code
                 and dd.code = p_item_code;
    return v_name;
  exception
    when NO_DATA_FOUND then
      return NULL;
  end getNameByCode;

  
  
  function getDictDsc(p_dict_code pls_integer) return DictCurTyp is
  /**
  declare
    p_dict_code pls_integer := 24;
    curDict PSHFT_DICTS.DictCurTyp;
    rcDictDsc SHFT_DICT_DSC%ROWTYPE;
  begin
    curDict := PSHFT_DICTS.getDict(p_dict_code);
    LOOP
      fetch curDict into rcDictDsc;
      exit when curDict%NOTFOUND;
      dbms_output.put_line('DICT_COD = ' || rcDictDsc.DICT_CODE || ': ' || rcDictDsc.DSC);
   end LOOP;
  end;
  */
    curDict DictCurTyp;
    v_sql varchar2(2000) := '';
    v_where varchar2(200) := '';
    v_orderby varchar2(200) := '';
  begin
    v_sql := 'select * from SHFT_DICT_DSC @WHERE @ORDERBY';
    if p_dict_code > 0 then 
      v_where := ' where dict_code = ' || p_dict_code;
    else
      v_orderby := ' order by dict_code';
    end if;  
    v_sql := replace(v_sql, '@WHERE', v_where);
    v_sql := replace(v_sql, '@ORDERBY', v_orderby);
    
    open curDict for v_sql;
    
    return curDict;
    
  end;

end PSHFT_DICTS;
/
