/*******************************************************************************
 * Copyright (c) 2007 Matthew Hall and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Matthew Hall - initial API and implementation (bug 206839)
 *******************************************************************************/

module org.eclipse.jface.internal.databinding.viewers.ViewerInputObservableValue;

import java.lang.all;

import org.eclipse.core.databinding.observable.Diffs;
import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.core.databinding.observable.value.AbstractObservableValue;
import org.eclipse.jface.util.Util;
import org.eclipse.jface.viewers.Viewer;

/**
 * Observes the input of a <code>Viewer</code>.
 * <p>
 * This observer is blind to changes in the viewer's input unless its
 * {@link #setValue(Object)} method is called directly.
 * 
 * @since 1.2
 */
public class ViewerInputObservableValue : AbstractObservableValue {

  private final Viewer viewer;

  /**
   * Constructs a new instance associated with the provided <code>viewer</code>.
   * 
   * @param realm
   * @param viewer
   */
  public this( Realm realm, Viewer viewer ) {
    super( realm );
    if ( viewer is null ) {
      throw new IllegalArgumentException( "The 'viewer' parameter is null." ); //$NON-NLS-1$
    }

    this.viewer = viewer;
  }

  /**
   * Sets the input to the provided <code>value</code>. Value change events are
   * fired after input is set in the viewer.
   * 
   * @param value object to set as input
   */
  protected void doSetValue( Object value ) {
    Object oldValue = doGetValue();
    viewer.setInput( value );
    if ( !Util.opEquals( oldValue, value ) ) {
      fireValueChange( Diffs.createValueDiff( oldValue, value ) );
    }
  }

  /**
   * Retrieves the current input.
   * 
   * @return the current input
   */
  protected Object doGetValue() {
    return viewer.getInput();
  }

  public Object getValueType() {
    return null;
  }
}
