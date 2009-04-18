/*******************************************************************************
 * Copyright (c) 2005, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Brad Reynolds - bug 164653
 *     Ashley Cambrell - bug 198904
 *******************************************************************************/
module org.eclipse.jface.internal.databinding.swt.TableSingleSelectionObservableValue;
import org.eclipse.jface.internal.databinding.swt.SingleSelectionObservableValue;

import java.lang.all;

import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.widgets.Table;

/**
 * @since 1.0
 * 
 */
public class TableSingleSelectionObservableValue :
        SingleSelectionObservableValue {

    private SelectionListener selectionListener;

    /**
     * @param table
     */
    public this(Table table) {
        super(table);
    }
    
    /**
     * @param realm
     * @param table
     */
    public this(Realm realm, Table table) {
        super(realm, table);
    }

    private Table getTable() {
        return cast(Table) getWidget();
    }

    protected void doAddSelectionListener(Runnable runnable) {
        selectionListener = new class(runnable) SelectionListener {
            Runnable runnable_;
            this(Runnable r){ runnable_ = r; }
            public void widgetDefaultSelected(SelectionEvent e) {
                runnable_.run();
            }

            public void widgetSelected(SelectionEvent e) {
                runnable_.run();
            }
        };
        getTable().addSelectionListener(selectionListener);
    }

    protected int doGetSelectionIndex() {
        return getTable().getSelectionIndex();
    }

    protected void doSetSelectionIndex(int index) {
        getTable().setSelection(index);
    }

    /*
     * (non-Javadoc)
     *
     * @see org.eclipse.core.databinding.observable.value.AbstractObservableValue#dispose()
     */
    public synchronized void dispose() {
        super.dispose();
        if (selectionListener !is null && !getTable().isDisposed()) {
            getTable().removeSelectionListener(selectionListener);
        }
    }
}
